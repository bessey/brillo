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
        Aws.config.update(aws_config(config.transfer_config))
      end

      def download
        return unless enabled
        logger.info("download #{path} from s3 #{bucket} #{filename}")
        FileUtils.rm path, force: true
        client.get_object({bucket: bucket, key: filename}, target: path)
      rescue Aws::S3::Errors::NoSuchBucket
        create_bucket
        retry
      end

      def upload
        return unless enabled
        logger.info("uploading #{path} to s3 #{bucket} #{filename}")
        object = resource.bucket(bucket).object(filename)
        object.upload_file(path)
      rescue Aws::S3::Errors::NoSuchBucket
        create_bucket
        retry
      end

      private

      def aws_config(transfer_config)
        {
          region: transfer_config.region
        }.tap do |hash|
          # Don't explicitly set credentials if we have none
          # Doing so stops [automatic configuration](https://github.com/aws/aws-sdk-ruby#configuration)
          return unless transfer_config.access_key_id
          hash[:credentials] = Aws::Credentials.new(
            transfer_config.access_key_id,
            transfer_config.secret_access_key
          )
        end
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
