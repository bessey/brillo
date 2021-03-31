module Brillo
  # Responsible for fetching an existing SQL scrub from S3, cleaning the database,
  # and loading the SQL.
  class Loader
    include Helpers::ExecHelper
    include Logger
    attr_reader :config

    def initialize(config)
      raise "⚠️ DON'T LOAD IN PRODUCTION! ⚠️" if production?
      @config = config
    end

    def load!(keep_local)
      download_sql(keep_local)
      recreate_db
      import_sql
    end

    def download_sql(keep_local)
      if keep_local
        path = config.compress ? config.compressed_dump_path : config.dump_path
        return if File.exists? path
      end

      config.transferrer.download
    end

    def recreate_db
      return unless config.recreate_db
      config.adapter.recreate_db
    end

    def import_sql
      if config.compress
        execute!("gunzip -c #{config.compressed_dump_path} | #{sql_load_command}")
      else
        execute!("cat #{config.dump_path} | #{sql_load_command}")
      end
      logger.info "Import complete!"
    end

    private

    def production?
      (ENV['RAILS_ENV'] || ENV['RUBY_ENV']) == 'production'
    end

    def sql_load_command
      config.adapter.load_command
    end
  end
end
