# frozen_string_literal: true

module Brillo
  # Responsible for creating a fresh scrubbed SQL copy of the database,
  # as specified via config, and uploading to S3
  class Scrubber
    include Helpers::ExecHelper
    include Logger
    JUMBLE_PRNG = Random.new
    LATEST_LIMIT = 1_000

    # Define some procs as scrubbing strategies for Polo
    SCRUBBERS = {
      default_time: ->(t) { t.nil? ? Time.now.to_s(:sql) : t },
      email: ->(e) { "#{Digest::MD5.hexdigest(e)}@example.com" },
      jumble: ->(j) { j.downcase.chars.shuffle!(random: JUMBLE_PRNG.clone).join },
      # strips extensions
      phone: ->(n) { n = n.split(' ').first; n && n.length > 9 ? n[0..-5] + n[-1] + n[-2] + n[-3] + n[-4] : n },
      name: lambda { |n|
        n.downcase.split(' ').map do |word|
          word.chars.shuffle!(random: JUMBLE_PRNG.clone).join
        end.each(&:capitalize!).join(' ')
      },
    }.freeze

    TACTICS = {
      latest: ->(klass) { klass.order("#{klass.primary_key} desc").limit(LATEST_LIMIT).pluck(klass.primary_key) },
      all: ->(klass) { klass.pluck(klass.primary_key) },
    }.freeze

    attr_reader :config, :adapter, :transferrer

    def initialize(config)
      @config = config
      @adapter = config.adapter
    end

    def scrub!
      FileUtils.rm(config.compressed_filename, force: true)
      configure_polo
      adapter.dump_structure_and_migrations(config)
      explore_all_classes
      compress
      config.transferrer.upload
    end

    def explore_all_classes
      File.open(config.dump_path, 'a') do |sql_file|
        sql_file.puts(adapter.header)
        klass_association_map.each do |klass, options|
          begin
            klass = deserialize_class(klass)
            tactic = deserialize_tactic(klass, options)
          rescue ConfigParseError => e
            logger.error("Error in brillo.yml: #{e.message}")
            next
          end
          associations = options.fetch(:associations, [])
          explore_class(klass, tactic, associations) do |insert|
            sql_file.puts(insert)
          end
        end
        ActiveRecord::Base.descendants.each do |klass|
          sql_file.puts(adapter.table_footer(klass))
        end
        sql_file.puts(adapter.footer)
      end
    end

    private

    def compress
      return unless config.compress

      execute!("gzip -f #{config.dump_path}")
    end

    def explore_class(klass, tactic_or_ids, associations)
      ids = tactic_or_ids.is_a?(Symbol) ? TACTICS.fetch(tactic_or_ids).call(klass) : tactic_or_ids
      logger.info("Scrubbing #{ids.length} #{klass} rows with associations #{associations}")
      ActiveRecord::Base.connection.uncached do
        Polo.explore(klass, ids, associations).each do |row|
          yield "#{row};"
        end
      end
    end

    def klass_association_map
      config.klass_association_map
    end

    def obfuscations
      config.obfuscations.transform_values do |strategy|
        SCRUBBERS.fetch(strategy)
      end
    end

    def configure_polo
      obfs = obfuscations
      adapter = config.db['adapter']
      Polo.configure do
        obfuscate(obfs)
        on_duplicate(:ignore) if adapter == 'mysql2'
      end
    end

    def deserialize_class(klass)
      klass.to_s.camelize.constantize
    rescue StandardError
      raise ConfigParseError, "Could not process class '#{klass}'"
    end

    def deserialize_tactic(klass, options)
      options.fetch(:tactic).to_sym
    rescue KeyError
      raise ConfigParseError, "Tactic not specified for class #{klass}"
    end
  end
end
