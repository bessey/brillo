module Brillo
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/brillo.rake"
    end
    generators do
      require "generators/brillo.rb"
    end
  end
end
