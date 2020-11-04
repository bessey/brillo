# frozen_string_literal: true

module Brillo
  module Generators
    # Install Generator
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      desc 'Install the Brillo'

      def copy_initializer
        copy_file('initializer.rb', 'config/initializers/brillo.rb')
      end

      def copy_config
        copy_file('initializer.rb', 'config/initializers/brillo.rb')
      end
    end
  end
end
