require 'yaml'

namespace :db do
  desc 'Upload a scrubbed copy of the database as specified by config/scrub.yml to S3'
  task :scrub => :environment do
    scrub_config = YAML.load_file("#{Rails.root.to_s}/config/brillo.yml")
    logger = ENV["VERBOSE"] ? Logger.new(STDOUT) : Rails.logger
    Brillo.new(scrub_config, logger: logger).scrub_to_s3
  end

  desc 'Load a previously created scrubbed database copy from S3'
  task :load => :environment do
    scrub_config = YAML.load_file("#{Rails.root.to_s}/config/brillo.yml")
    Brillo.new(scrub_config, logger: Logger.new(STDOUT)).load_from_s3
  end
end
