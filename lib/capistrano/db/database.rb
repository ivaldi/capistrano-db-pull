module Database
  class Base
    attr_accessor :capistrano, :config

    def initialize(instance)
      @capistrano = instance
    end

    def postgresql?
      adapter == 'pg' || adapter == 'postgresql'
    end

    def sqlite3?
      adapter == 'sqlite3'
    end

    def mysql?
      adapter == 'mysql2' || adapter == 'mysql'
    end

    def adapter
      @config['adapter'].downcase
    end
  end

  class Remote < Base
    def initialize(instance, stage)
      super(instance)
      config = @capistrano.capture(
          "cat #{@capstrano.current_path}/config/database.yml")
      @config = YAML.load(ERB.new(config).result)[stage.to_s]
    end
  end

  class Local < Base
    def initialize(instance)
      super(instance)
      config = File.read('config/database.yml')
      @config = YAML.load(ERB.new(config).result)['development']
    end
  end
end
