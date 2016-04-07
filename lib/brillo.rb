require "brillo/version"
require 'brillo/railtie'
require 'brillo/common'
require 'brillo/config'
require 'brillo/scrubber'
require 'brillo/loader'
require 'polo'

module Brillo
  def self.scrub!(logger: Logger.new(STDOUT))
    Scrubber.new(yaml_config, logger: logger).scrub!
  end

  def self.load!(logger: Logger.new(STDOUT))
    Loader.new(yaml_config, logger: logger).load!
  end

  def self.yaml_config
    YAML.load_file("#{Rails.root.to_s}/config/brillo.yml")
  end
end
