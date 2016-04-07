module Brillo
  module Common
    attr_reader :s3_keys

    def parse_config(config)
      @config = Config.new(config)
    end

    private

    def load_aws_keys
      if File.exist?(config.aws_key_path)
        @s3_keys = YAML.load_file(config.aws_key_path)
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
