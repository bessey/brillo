module Brillo
  # Responsible for creating a fresh scrubbed SQL copy of the database,
  # as specified via config, and uploading to S3
  class Scrubber
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

    attr_reader :config, :logger

    def initialize(config, logger: Rails.logger)
      parse_config(config)
      load_aws_keys
      @logger = logger
    end

    def scrub!
      configure_polo
      dump_structure_and_migrations
      explore_all_classes
      send_to_s3
    end

    def explore_all_classes
      File.open(config.dump_path, "a") do |sql_file|
        klass_association_map.each do |klass, options|
          klass = deserialize_class(klass)
          begin
            tactic = options.fetch("tactic").to_sym
          rescue KeyError
            raise Config::ParseError, "Tactic not specified for class #{klass}"
          end
          associations = options.fetch("associations", [])
          explore_class(klass, tactic, associations) do |insert|
            sql_file.puts(insert)
          end
        end
      end
    end

    def send_to_s3
      return unless config.send_to_s3
      `gzip -f #{config.dump_path}` if config.compress
      command = "#{aws_command} put #{config.s3_bucket}/#{config.remote_filename} #{config.remote_path}"
      logger.info "Uploading #{config.remote_path} to S3"
      stdout_and_stderr_str, status = Open3.capture2e([aws_env, command].join(' '))
      raise stdout_and_stderr_str if !status.success?
    end

    private

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
      config.obfuscations
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
      # Overrides the path the structure is dumped to in Rails >= 3.2
      ENV['SCHEMA'] = ENV['DB_STRUCTURE'] = config.remote_path.to_s
      Rake::Task["db:structure:dump"].invoke
    end

    def deserialize_class(klass)
      klass.camelize.constantize
    rescue
      raise ParseError, "Could not process class '#{klass}'"
    end
  end
end
