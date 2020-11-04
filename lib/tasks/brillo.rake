# frozen_string_literal: true

require 'yaml'

namespace :db do
  desc 'Upload a scrubbed copy of the database as specified by config/scrub.yml to S3'
  task scrub: :environment do
    logger = ENV['VERBOSE'] ? Logger.new($stdout) : Rails.logger
    logger.level = ENV['VERBOSE'] ? Logger::DEBUG : Logger::WARN
    begin
      Brillo.scrub!(logger: logger)
    rescue Brillo::CredentialsError => e
      puts e
      exit(1)
    end
  end

  desc 'Load a previously created scrubbed database copy from S3'
  task load: :environment do
    Brillo.load!
  rescue Brillo::CredentialsError => e
    puts e
    exit(1)
  end
end
