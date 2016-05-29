module Brillo
  # Responsible for creating a fresh scrubbed SQL copy of the database,
  # as specified via config, and uploading to S3
  class Scrubber
    include Helpers::ExecHelper
    include Logger
    include Common
    JUMBLE_PRNG = Random.new
    LATEST_LIMIT = 1_000

    # Define some procs as scrubbing strategies for Polo
    SCRUBBERS = {
      default_time: ->(t) { t.nil? ? Time.now.to_s(:sql) : t },
      email:        ->(e) { e.match(/@caring.com/) ? e : Digest::MD5.hexdigest(e) + "@example.com".freeze },
      jumble:       ->(j) { j.downcase.chars.shuffle!(random: JUMBLE_PRNG.clone).join },
      phone:        ->(n) { n = n.split(' ').first; n && n.length > 9 ? n[0..-5] + n[-1] + n[-2] + n[-3] + n[-4] : n},   # strips extensions
      name:         ->(n) { n.downcase.split(' ').map do |word|
          word.chars.shuffle!(random: JUMBLE_PRNG.clone).join
        end.each(&:capitalize!).join(' ')
      },
    }

    TACTICS = {
      latest: -> (klass) { klass.order('id desc').limit(LATEST_LIMIT).pluck(:id) },
      all:    -> (klass) { klass.pluck(:id) }
    }

    attr_reader :config

    def initialize(config)
      @config = config
      load_aws_keys
    end

    def scrub!
      FileUtils.rm [config.dump_path, config.remote_path], force: true
      configure_polo
      dump_structure_and_migrations
      explore_all_classes
      compress
      send_to_s3
    end

    def explore_all_classes
      File.open(config.dump_path, "a") do |sql_file|
        sql_file.puts(adapter_header)
        klass_association_map.each do |klass, options|
          begin
            klass = deserialize_class(klass)
            tactic = deserialize_tactic(options)
          rescue ConfigParseError => e
            logger.error "Error in brillo.yml: #{e.message}"
            next
          end
          associations = options.fetch("associations", [])
          explore_class(klass, tactic, associations) do |insert|
            sql_file.puts(insert)
          end
        end
        sql_file.puts(adapter_footer)
      end
    end

    def send_to_s3
      return unless config.send_to_s3
      logger.info "Uploading #{config.remote_path} to S3"
      aws_s3 "put"
    end

    private

    def compress
      return unless config.compress
      execute!("gzip -f #{config.dump_path}")
    end

    def explore_class(klass, tactic_or_ids, associations)
      ids = tactic_or_ids.is_a?(Symbol) ? TACTICS.fetch(tactic_or_ids).call(klass) : tactic_or_ids
      logger.info("Scrubbing #{ids.length} #{klass} rows with associations #{associations}")
      Polo.explore(klass, ids, associations).each do |row|
        yield "#{row};"
      end
    end

    def klass_association_map
      config.klass_association_map
    end

    def obfuscations
      config.obfuscations.map do |field, strategy|
        [field, SCRUBBERS.fetch(strategy)]
      end.to_h
    end

    def configure_polo
      obfs = obfuscations
      adapter = config.db[:adapter]
      Polo.configure do
        obfuscate obfs
        if adapter == "mysql2"
          on_duplicate :ignore
        end
      end
    end

    def dump_structure_and_migrations
      case config.db[:adapter]
      when 'mysql2'
        Dumper::MysqlDumper.new(config).dump
      else
        # Overrides the path the structure is dumped to in Rails >= 3.2
        ENV['SCHEMA'] = ENV['DB_STRUCTURE'] = config.dump_path.to_s
        Rake::Task["db:structure:dump"].invoke
      end
    end

    def deserialize_class(klass)
      klass.camelize.constantize
    rescue
      raise Config::ConfigParseError, "Could not process class '#{klass}'"
    end

    def deserialize_tactic(options)
      options.fetch("tactic").to_sym
    rescue KeyError
      raise ConfigParseError, "Tactic not specified for class #{klass}"
    end

    def adapter_header
      return unless config.db[:adapter] == "mysql2"
      ActiveRecord::Base.connection.dump_schema_information +
        <<-SQL
        -- Disable autocommit, uniquechecks, and foreign key checks, for performance on InnoDB
        -- http://dev.mysql.com/doc/refman/5.5/en/optimizing-innodb-bulk-data-loading.html
        SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, AUTOCOMMIT = 0;
        SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS = 0;
        SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;
        SQL
    end

    def adapter_footer
      return unless config.db[:adapter] == "mysql2"
      <<-SQL
      SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
      SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
      SET AUTOCOMMIT = @OLD_AUTOCOMMIT;
      COMMIT;
      SQL
    end
  end
end
