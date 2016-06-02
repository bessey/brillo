require 'aws-sdk'

module Brillo
  module Transferrer
    class S3
      include Helpers::ExecHelper
      include Logger
      attr_reader :bucket, :filename, :region, :path, :enabled

      def initialize(config)
        @enabled              = config.transfer_config.enabled
        @bucket               = config.transfer_config.bucket
        @region               = config.transfer_config.region
        @filename             = config.compressed_filename
        @path                 = config.compressed_dump_path
        set_environment
      end

      def download
        return unless enabled
        FileUtils.rm path, force: true
        client.get_object({bucket: bucket, key: path.to_s}, target: path)
      rescue Aws::S3::Errors::NoSuchBucket
        create_bucket
        retry
      end

      def upload
        return unless enabled
        object = resource.bucket(bucket).object(path.to_s)
        object.upload_file(path)
      rescue Aws::S3::Errors::NoSuchBucket
        create_bucket
        retry
      end

      private

      # Backwards compatibility only
      def set_environment
        ENV['AWS_SECRET_ACCESS_KEY'] ||= (ENV["AWS_SECRET_KEY"] || ENV["EC2_SECRET_KEY"])
        ENV['AWS_ACCESS_KEY_ID']     ||= (ENV["AWS_ACCESS_KEY"] || ENV["EC2_ACCESS_KEY"])
        ENV['AWS_REGION']            ||= region
      end

      def create_bucket
        client.create_bucket(bucket: bucket)
      end

      def client
        Aws::S3::Client.new
      end

      def resource
        Aws::S3::Resource.new
      end
    end
  end
end
