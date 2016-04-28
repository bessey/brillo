module Brillo
  # Responsible for fetching an existing SQL scrub from S3, cleaning the database,
  # and loading the SQL.
  class Loader
    include Helpers::ExecHelper
    include Logger
    include Common
    attr_reader :config

    def initialize(config)
      raise "⚠️ DON'T LOAD IN PRODUCTION! ⚠️" if Rails.env.production?
      parse_config(config)
      load_aws_keys
    end

    def load!
      get_from_s3
      recreate_db
      import_sql
    end

    def get_from_s3
      return unless config.fetch_from_s3
      FileUtils.rm [config.dump_path, config.remote_path], force: true
      logger.info "Downloading #{config.remote_filename} from S3"
      aws_s3 "get"
    end

    def recreate_db
      ["db:drop", "db:create"].each do |t|
        logger.info "Running\n\trake #{t}"
        Rake::Task[t].invoke
      end
    end

    def import_sql
      if config.compress
        execute!("gunzip -c #{config.remote_path} | #{sql_load_command}")
      else
        execute!("cat #{config.dump_path} | #{sql_load_command}")
      end
      logger.info "Import complete!"
    end

    private

    def sql_load_command
      db = config.db
      case db[:adapter]
      when "mysql2"
        "mysql --host #{db[:host]} -u #{db[:username]} #{db[:password] ? "-p#{db[:password]}" : ""} #{db[:database]}"
      when "postgresql"
        "psql --host #{db[:host]} -U #{db[:username]} #{db[:password] ? "-W#{db[:password]}" : ""} #{db[:database]}"
      else
        raise "Unsupported DB adapter #{db[:adapter]}"
      end
    end
  end
end
