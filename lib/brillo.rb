require "brillo/version"
require 'brillo/railtie'
require 'polo'

class Brillo
  AWS_KEY_PATH = '/etc/ec2_secure_env.yml'
  S3_BUCKET = 'scrubbed_databases2'
  JUMBLE_PRNG = Random.new
  LATEST_LIMIT = 1_000
  ParseError = StandardError.new

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

  attr_reader :scrub_name, :logger, :s3_keys, :dry_run, :klass_association_map, :obfuscations

  def initialize(config, logger: Rails.logger)
    parse_config(config)
    load_aws_keys
    @logger = logger
  end

  def scrub_to_s3
    dump_structure_and_migrations_to(scrub_path)
    configure_polo
    File.open(scrub_path, "a") do |sql_file|
      klass_association_map.each do |klass, options|
        klass = deserialize_class(klass)
        begin
          tactic = options.fetch("tactic").to_sym
        rescue KeyError
          raise ParseError, "Tactic not specified for class #{klass}"
        end
        associations = options.fetch("associations", [])
        explore_class(klass, tactic, associations) do |insert|
          sql_file.puts(insert)
        end
      end
    end
    s3_put! scrub_path unless dry_run
  end

  def load_from_s3
    raise "Do not do this" if Rails.env.production?

    unless ENV['skip_download']
      FileUtils.rm [dump_path, scrub_path], force: true
      s3_get!(scrub_filename, scrub_path)
    end
    `gunzip #{scrub_path}`

    ["db:drop", "db:create"].each do |t|
      Rake::Task[t].invoke
    end

    case db_config[:adapter]
    when "mysql2"
      `mysql --host #{db_config[:host]} -u #{db_config[:username]} #{db_config[:password] ? "-p#{db_config[:password]}" : ""} #{db_config[:database]} < #{dump_path}`
    when "postgresql"
      `psql --host #{db_config[:host]} -U #{db_config[:username]} #{db_config[:password] ? "-W#{db_config[:password]}" : ""} #{db_config[:database]} < #{dump_path}`
    else
      raise "Unsupported DB adapter #{db_config[:adapter]}"
    end
  end

  def explore_class(klass, tactic_or_ids, associations)
    ids = tactic_or_ids.is_a?(Symbol) ? TACTICS.fetch(tactic_or_ids).call(klass) : tactic_or_ids
    logger.info("Scrubbing #{ids.length} #{klass} rows with associations #{associations}")
    Polo.explore(klass, ids, associations).each do |row|
      yield "#{row};"
    end
  end

  private

  def parse_config(config)
    @scrub_name            = config.fetch("name")
    @dry_run               = config.fetch("dry_run", false)
    @klass_association_map = config.fetch("explore")
    @obfuscations          = parse_obfuscations config.fetch("obfuscations", {})
  end

  def configure_polo
    obfs = obfuscations
    adapter = db_config[:adapter]
    Polo.configure do
      obfuscate obfs
      if adapter == "mysql2"
        on_duplicate :ignore
      end
    end
  end

  def s3_put!(path)
    `mv #{scrub_path} #{dump_path} && gzip #{dump_path}`
    command = "#{aws_command} put #{S3_BUCKET}/#{scrub_filename} #{scrub_path}"
    logger.info("Uploading #{scrub_path} to S3")
    stdout_and_stderr_str, status = Open3.capture2e([aws_env, command].join(' '))
    raise stdout_and_stderr_str if !status.success?
  end

  def s3_get!(source, dest)
    command = "#{aws_command} get #{S3_BUCKET}/#{source} #{dest}"
    stdout_and_stderr_str, status = Open3.capture2e([aws_env, command].join(' '))
    raise stdout_and_stderr_str if !status.success?
  end

  # Convert generic cross table obfuscations to symbols so Polo parses them correctly
  # "my_table.field" => "my_table.field"
  # "my_field"       => :my_field
  def parse_obfuscations(obfuscations)
    obfuscations.each_pair.with_object({}) do |field_and_strategy, hash|
      field, strategy = field_and_strategy
      begin
        strategy_lambda = SCRUBBERS.fetch(strategy.to_sym)
      rescue KeyError
        raise ParseError, "Scrub strategy '#{strategy}' not found"
      end
      field.match(/\./) ? hash[field] = strategy_lambda : hash[field.to_sym] = strategy_lambda
    end
  end

  def dump_structure_and_migrations_to(path)
    # Overrides the path the structure is dumped to in Rails >= 3.2
    ENV['SCHEMA'] = ENV['DB_STRUCTURE']  = path.to_s
    Rake::Task["db:structure:dump"].invoke
  end

  def deserialize_class(klass)
    klass.camelize.constantize
  rescue
    raise ParseError, "Could not process class '#{klass}'"
  end

  def load_aws_keys
    return if ENV['NO_PUSH']
    if File.exist?(AWS_KEY_PATH)
      @s3_keys = YAML.load_file(AWS_KEY_PATH)
    else
      key = ENV["AWS_SECRET_KEY"] || ENV["EC2_SECRET_KEY"]
      unless key && key.length > 10
        raise "AWS keys not available. Did you . /etc/ec2_secure_env?"
      end
      @s3_keys = {
        'aws_access_key' => ENV["AWS_ACCESS_KEY"] || ENV["EC2_ACCESS_KEY"],
        'aws_secret_key' => key
      }
    end
  end

  def db_config
    @db_config ||= ActiveRecord::Base.connection.instance_variable_get(:@config)
  end

  def aws_env
    "EC2_ACCESS_KEY=#{s3_keys['aws_access_key']} EC2_SECRET_KEY=#{s3_keys['aws_secret_key']}"
  end

  def app_tmp
    Rails.root.join "tmp"
  end

  def dump_filename
    "#{scrub_name}-scrubbed.dmp"
  end

  def dump_path
    app_tmp + dump_filename
  end

  def scrub_filename
    "#{dump_filename}.gz"
  end

  def scrub_path
    app_tmp + scrub_filename
  end

  def aws_command
    if File.exist?('/usr/local/bin/awstk')
      '/usr/local/bin/awstk'
    else
      '/usr/local/bin/aws'
    end
  end
end
