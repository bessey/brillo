require "brillo/version"

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
  def self.scrub!(logger: Logger.new(STDOUT))
    Brillo::Logger.logger = logger
    Scrubber.new(yaml_config).scrub!
  end

  def self.load!(logger: Logger.new(STDOUT))
    Brillo::Logger.logger = logger
    Loader.new(yaml_config).load!
  end

  def self.yaml_config
    YAML.load_file("#{Rails.root.to_s}/config/brillo.yml")
  end
end
