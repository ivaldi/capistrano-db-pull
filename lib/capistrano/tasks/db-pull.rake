namespace :db do
  task :pull do
    remote = nil
    on roles(:db) do
      remote = Application::Remote.new(self, fetch(:stage) || 'production')
      if remote.postgresql?
        execute "#{Database.factory(remote).dump} | gzip -9 > #{fetch(:application)}.sql.gz"
      elsif remote.mysql?
        execute "mysqldump --skip-opt --no-create-info #{remote.database} | gzip -9 > #{fetch(:application)}.sql.gz"
      else
        raise "Remote database adapter '#{remote.adapter}' is currently unsupported"
      end
      download! "#{fetch(:application)}.sql.gz", "#{fetch(:application)}.sql.gz"
      execute "rm #{fetch(:application)}.sql.gz"
    end

    local = Application::Local.new(self)
    if remote.postgresql? && local.sqlite3?
      system "echo 'BEGIN;' > #{fetch(:application)}.sql"
      system "gunzip -c #{fetch(:application)}.sql.gz | sed '/^SET/ d' |\
        sed '/^SELECT pg_catalog.setval/ d' |\
        sed \"s/ true,/ 't',/g\" |\
        sed \"s/ false,/ 'f',/g\" |\
        sed \"s/(true/('t'/g\" |\
        sed \"s/(false/('f'/g\" |\
        sed \"s/true)/'t')/g\" |\
        sed \"s/false)/'f')/g\" >> #{fetch(:application)}.sql"
      system "echo 'END;' >> #{fetch(:application)}.sql"
    elsif remote.mysql? && local.sqlite3?
      system "gunzip -c #{fetch(:application)}.sql.gz |
          sed 's/\\`//g' |
          sed \"s/\\\\\\\'/\'\'/g\" |
          sed 's/\\\"/\"/g' > #{fetch(:application)}.sql"
    else
      raise "Local database adapter '#{local.adapter}' is currently unsupported"
    end
    system "bin/rake db:drop && bin/rake db:schema:load &&
        cat #{fetch(:application)}.sql | sqlite3 db/development.sqlite3"

    system "rm #{fetch(:application)}.sql"
    system "rm #{fetch(:application)}.sql.gz"
  end
end
