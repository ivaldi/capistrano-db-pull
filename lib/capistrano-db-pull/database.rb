module Database
  def self.factory application
    if application.postgresql?
      Database::PostgreSQL.new
    elsif application.sqlite3?
      Database::SQLite3.new
    elsif application.mysql?
      Database::MySQL.new
    else
      raise 'Not implemented'
    end
  end

  class Base

    def dump
      raise 'Not implemented'
    end

    def load filename
      raise 'Not implemented'
    end
  end

  class PostgreSQL < Base
  end

  class Sqlite3 < Base
  end

  class MySQL < Base
  end
end
