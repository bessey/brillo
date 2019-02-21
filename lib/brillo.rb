require 'yaml'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/string/inflections'
require 'active_record'
require "brillo/version"

require 'brillo/errors'
require 'brillo/helpers/exec_helper'
require 'brillo/logger'

require 'brillo/adapter/base'
require 'brillo/adapter/mysql'
require 'brillo/adapter/postgres'

require 'brillo/transferrer/config'
require 'brillo/transferrer/s3'

require 'brillo/dumper/mysql_dumper'
require 'brillo/railtie'
require 'brillo/config'
require 'brillo/scrubber'
require 'brillo/loader'
require 'polo'

module Brillo
  def self.configure
    yield config
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
      static_config = YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/brillo.yml")).result).deep_symbolize_keys
      Config.new(static_config)
    end
  end

  def self.config=(config)
    @config = config
  end
end
