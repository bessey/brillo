module Brillo
  module Transferrer
    class S3
      include Helpers::ExecHelper
      include Logger
      attr_reader :credentials, :bucket, :remote_filename, :remote_path, :download_enabled, :upload_enabled
      attr_reader :key_path

      def initialize(config)
        @download_enabled = config.fetch_from_s3
        @upload_enabled   = config.send_to_s3
        @bucket           = config.s3_bucket
        @key_path         = config.aws_key_path
        @remote_filename  = config.remote_filename
        @remote_path      = config.remote_path
        load_credentials
      end

      def download
        return unless download_enabled
        load_credentials
        FileUtils.rm [config.dump_path, config.remote_path], force: true
        aws_s3 "get"
      end

      def upload
        return unless upload_enabled
        load_credentials
        aws_s3 "put"
      end

      private

      def load_credentials
        if File.exist?(key_path)
          @credentials = YAML.load_file(key_path)
        else
          key = ENV["AWS_SECRET_KEY"] || ENV["EC2_SECRET_KEY"]
          unless key && key.length > 10
            raise "AWS keys not available. Did you . /etc/ec2_secure_env?"
          end
          @credentials = {
            'aws_access_key' => ENV["AWS_ACCESS_KEY"] || ENV["EC2_ACCESS_KEY"],
            'aws_secret_key' => key
          }
        end
      end

      def aws_s3 api_command
        execute!("#{aws_env} #{aws_bin} #{api_command} #{bucket}/#{remote_filename} #{remote_path}")
      end

      def aws_bin
        if File.exist?('/usr/local/bin/awstk')
          '/usr/local/bin/awstk'
        else
          '/usr/local/bin/aws'
        end
      end

      def aws_env
        "EC2_ACCESS_KEY=#{credentials['aws_access_key']} EC2_SECRET_KEY=#{credentials['aws_secret_key']}"
      end
    end
  end
end
