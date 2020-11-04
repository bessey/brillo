# frozen_string_literal: true

class BrilloConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('../..', __dir__)

  desc 'Create a plain Brillo YAML configuration and initializer'
  def create_initializer_file
    copy_file('config/brillo-example.yml', 'config/brillo.yml')
    copy_file('config/brillo-initializer.rb', 'config/initializers/brillo.rb')
  end
end
