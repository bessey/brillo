module Brillo
  module Transferrer
    class Config
      attr_reader :bucket, :region, :enabled
      def initialize(bucket: 'database-scrubs', region: 'us-west-2', enabled: true)
        @enabled = enabled
        @bucket = bucket
        @region = region
      end
    end
  end
end
