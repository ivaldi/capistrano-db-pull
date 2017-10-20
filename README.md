# Capistrano DB Pull

Replace your local development database with a database pulled from the server.

## Getting Started

* Add `gem capistrano-db-pull` to the :development group in your Gemfile
* Add `require 'capistrano/db/pull` to your Capfile

## How To Use

* Run `cap <STAGE> db:pull`, e.g. `cap production db:pull` to pull your production database
