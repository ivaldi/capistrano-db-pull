namespace :db do
  task :pull do
    remote = nil
    local = Application::Local.new(self)

    on roles(:db) do
      remote = Application::Remote.new(self, fetch(:rails_env) || 'production')
      if remote.postgresql? && local.postgresql?
        execute "pg_dump --no-owner #{remote.database} | gzip -9 > #{fetch(:application)}.sql.gz"
      elsif remote.postgresql? && local.sqlite3?
        execute "pg_dump --data-only --exclude-table=schema_migrations --column-inserts #{remote.database} | gzip -9 > #{fetch(:application)}.sql.gz"
      elsif remote.mysql?
        execute "mysqldump --skip-opt --routines --triggers --events #{remote.database} | gzip -9 > #{fetch(:application)}.sql.gz"
      else
        raise "Remote database adapter '#{remote.adapter}' is currently unsupported"
      end
      download! "#{fetch(:application)}.sql.gz", "#{fetch(:application)}.sql.gz"
      execute "rm #{fetch(:application)}.sql.gz"
    end

    if remote.postgresql? && local.postgresql?
      system 'bin/rake db:drop && bin/rake db:create'
      system "gunzip -c #{fetch(:application)}.sql.gz | psql #{local.database}"
      system 'bin/rails db:environment:set RAILS_ENV=development'
    elsif remote.postgresql? && local.sqlite3?
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
      system "bin/rake db:drop && bin/rake db:schema:load &&
          cat #{fetch(:application)}.sql | sqlite3 db/development.sqlite3"
    elsif remote.mysql? && local.sqlite3?
      system "gunzip -c #{fetch(:application)}.sql.gz |
          sed 's/\\`//g' |
          sed \"s/\\\\\\\'/\'\'/g\" |
          sed 's/\\\"/\"/g' > #{fetch(:application)}.sql"
      system "bin/rake db:drop && bin/rake db:schema:load &&
          cat #{fetch(:application)}.sql | sqlite3 db/development.sqlite3"
    elsif remote.mysql? && local.mysql?
      system 'bin/rake db:drop'
      system 'bin/rake db:create'
      system "gunzip -c #{fetch(:application)}.sql.gz | mysql #{local.database}"
      system 'bin/rails db:environment:set RAILS_ENV=development'
    else
      raise "Local database adapter '#{local.adapter}' is currently unsupported"
    end

    system "rm -f #{fetch(:application)}.sql"
    system "rm -f #{fetch(:application)}.sql.gz"
  end
end
