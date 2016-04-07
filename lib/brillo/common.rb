module Brillo
  module Common
    AWS_KEY_PATH = '/etc/ec2_secure_env.yml'
    S3_BUCKET = 'scrubbed_databases2'

    attr_reader :s3_keys

    def parse_config(config)
      @config = Config.new(config)
    end

    private

    def load_aws_keys
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

    def aws_command
      if File.exist?('/usr/local/bin/awstk')
        '/usr/local/bin/awstk'
      else
        '/usr/local/bin/aws'
      end
    end

    def aws_env
      "EC2_ACCESS_KEY=#{s3_keys['aws_access_key']} EC2_SECRET_KEY=#{s3_keys['aws_secret_key']}"
    end
  end
end
