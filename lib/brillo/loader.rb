# frozen_string_literal: true

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

    def load!
      config.transferrer.download
      recreate_db
      import_sql
    end

    def recreate_db
      config.adapter.recreate_db
    end

    def import_sql
      if config.compress
        execute!("gunzip -c #{config.compressed_dump_path} | #{sql_load_command}")
      else
        execute!("cat #{config.dump_path} | #{sql_load_command}")
      end
      logger.info('Import complete!')
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
