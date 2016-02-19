namespace :db do
  task :pull do
    on roles(:db) do
      execute "pg_dump --data-only --exclude-table=schema_migrations --column-inserts | gzip -9 > #{fetch(:application)}.sql.gz"
      download! "#{fetch(:application)}.sql.gz", "#{fetch(:application)}.sql.gz"
      execute "rm #{fetch(:application)}.sql.gz"
    end

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

    system "rm #{fetch(:application)}.sql"
    system "rm #{fetch(:application)}.sql.gz"
  end
end
