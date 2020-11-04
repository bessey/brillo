# frozen_string_literal: true

module Brillo
  module Transferrer
    class Config
      attr_accessor :bucket, :region, :enabled, :secret_access_key, :access_key_id

      def initialize(bucket: 'database-scrubs', region: 'us-east-1', enabled: true)
        @enabled = enabled
        @bucket = bucket
        @region = region
      end

      def region
        @region || ENV['AWS_REGION']
      end

      def secret_access_key
        @secret_access_key || ENV['AWS_SECRET_ACCESS_KEY'] || ENV['AWS_SECRET_KEY'] || ENV['EC2_SECRET_KEY']
      end

      def access_key_id
        @access_key_id || ENV['AWS_ACCESS_KEY_ID'] || ENV['AWS_ACCESS_KEY'] || ENV['EC2_ACCESS_KEY']
      end
    end
  end
end
