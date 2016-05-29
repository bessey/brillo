require "brillo/version"

require 'brillo/errors'
require 'brillo/helpers/exec_helper'
require 'brillo/logger'
require 'brillo/common'

require 'brillo/dumper/mysql_dumper'
require 'brillo/railtie'
require 'brillo/config'
require 'brillo/scrubber'
require 'brillo/loader'
require 'polo'

module Brillo
  def self.configure
    yield config
    config.verify!
  end

  def self.scrub!(logger: ::Logger.new(STDOUT))
    Brillo::Logger.logger = logger
    Scrubber.new(config).scrub!
  end

  def self.load!(logger: ::Logger.new(STDOUT))
    Brillo::Logger.logger = logger
    Loader.new(config).load!
  end

  def self.config
    @config ||= begin
      static_config = YAML.load_file("#{Rails.root.to_s}/config/brillo.yml")
      Config.new(static_config)
    end
  end

  def self.config=(config)
    @config = config
  end
end
