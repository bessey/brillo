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

  def self.scrub!(logger: ::Logger.new(STDOUT), filename: nil)
    Brillo::Logger.logger = logger
    configuration = config
    configuration.app_name = filename if filename
    Scrubber.new(configuration).scrub!
  end

  def self.load!(keep_local: false, logger: ::Logger.new(STDOUT), filename: nil)
    Brillo::Logger.logger = logger
    configuration = config
    configuration.app_name = filename if filename
    Loader.new(configuration).load! keep_local
  end

  def self.config
    @config ||= begin
      static_config = YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/brillo.yml")).result).deep_symbolize_keys
      c = Config.new(static_config)
      yield c if block_given?
      c
    end
  end

  def self.config=(config)
    @config = config
  end
end
