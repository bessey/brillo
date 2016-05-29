require 'yaml'

namespace :db do
  desc 'Upload a scrubbed copy of the database as specified by config/scrub.yml to S3'
  task :scrub => :environment do
    logger = ENV["VERBOSE"] ? Logger.new(STDOUT) : Rails.logger
    logger = Logger.new(STDOUT)
    logger.level = ENV["VERBOSE"] ? Logger::DEBUG : Logger::WARN
    begin
      Brillo.scrub!(logger: logger)
    rescue CredentialsError => e
      puts e
      exit(1)
    end
  end

  desc 'Load a previously created scrubbed database copy from S3'
  task :load => :environment do
    begin
      Brillo.load!
    rescue CredentialsError => e
      puts e
      exit(1)
    end
  end
end
