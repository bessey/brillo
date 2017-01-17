if defined? Rails
  module Brillo
    class Railtie < Rails::Railtie
      rake_tasks do
        load "tasks/brillo.rake"
      end
      generators do
        require "generators/brillo.rb"
      end
      config.after_initialize do
        Brillo.configure do |config|
          begin
            config.verify!
          rescue ConfigParseError => e
            puts "Brillo config contains errors: #{e}"
          end
        end
      end
    end
  end
end
