module Brillo
  class Config
    ParseError = StandardError.new
    AWS_KEY_PATH = '/etc/ec2_secure_env.yml'
    S3_BUCKET = 'scrubbed_databases2'
    attr_reader :app_name, :compress, :obfuscations, :klass_association_map, :db, :send_to_s3, :fetch_from_s3,
      :aws_key_path, :s3_bucket

    def initialize(options = {})
      @app_name = options.fetch("name")
      @obfuscations = parse_obfuscations(options["obfuscations"] || {})
      @klass_association_map = options.fetch("explore")
      @compress = options.fetch("compress",  true)
      @fetch_from_s3 = options.fetch("fetch_from_s3", true)
      @send_to_s3 = options.fetch("send_to_s3", true)
      @aws_key_path = options.fetch("aws_key_path", AWS_KEY_PATH)
      @s3_bucket = options.fetch("s3_bucket", S3_BUCKET)
    rescue KeyError => e
      raise ParseError, e
    end

    def app_tmp
      Rails.root.join "tmp"
    end

    def dump_filename
      "#{app_name}-scrubbed.dmp"
    end

    def remote_filename
      compress ? "#{dump_filename}.gz" : dump_filename
    end

    def dump_path
      app_tmp + dump_filename
    end

    def remote_path
      app_tmp + remote_filename
    end

    def db
      @db_config ||= ActiveRecord::Base.connection.instance_variable_get(:@config)
    end

    # Convert generic cross table obfuscations to symbols so Polo parses them correctly
    # "my_table.field" => "my_table.field"
    # "my_field"       => :my_field
    def parse_obfuscations(obfuscations)
      obfuscations.each_pair.with_object({}) do |field_and_strategy, hash|
        field, strategy = field_and_strategy
        begin
          strategy_lambda = Scrubber::SCRUBBERS.fetch(strategy.to_sym)
        rescue KeyError
          raise ParseError, "Scrub strategy '#{strategy}' not found"
        end
        field.match(/\./) ? hash[field] = strategy_lambda : hash[field.to_sym] = strategy_lambda
      end
    end
  end
end
