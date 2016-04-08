module Brillo
  # Responsible for fetching an existing SQL scrub from S3, cleaning the database,
  # and loading the SQL.
  class Loader
    include Common
    attr_reader :config, :logger

    def initialize(config, logger: Rails.logger)
      raise "⚠️ DON'T LOAD IN PRODUCTION! ⚠️" if Rails.env.production?
      parse_config(config)
      load_aws_keys
      @logger = logger
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
      load_command = if config.compress
        "zcat #{config.dump_path} | #{sql_load_command}"
      else
        "cat #{config.dump_path} | #{sql_load_command}"
      end
      logger.info "Running\n\t#{load_command}"
      stdout_and_stderr_str, status = Open3.capture2e(load_command)
      raise stdout_and_stderr_str if !status.success?
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
