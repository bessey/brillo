# frozen_string_literal: true

if defined? Rails
  module Brillo
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/brillo.rake'
      end

      generators do
        require 'generators/brillo/install_generator'
      end

      config.after_initialize do
        Brillo.configure do |config|
          config.verify!
        rescue ConfigParseError => e
          puts "Brillo config contains errors: #{e}"
        end
      end
    end
  end
end
