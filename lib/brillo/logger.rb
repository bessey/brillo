module Brillo
  module Logger
    def self.logger= logger
      @logger = logger
    end

    def self.logger
      @logger ||= Rails.logger
    end

    def logger
      Brillo::Logger.logger
    end
  end
end
