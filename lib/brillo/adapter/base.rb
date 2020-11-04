# frozen_string_literal: true

module Brillo
  module Adapter
    class Base
      include Logger

      attr_reader :config

      def initialize(db_config)
        @config = db_config
      end

      def header
        ActiveRecord::Base.connection.dump_schema_information
      end

      def footer
        ''
      end

      def table_footer(_klass)
        ''
      end

      def dump_structure_and_migrations(config)
        # Overrides the path the structure is dumped to in Rails >= 3.2
        ENV['SCHEMA'] = ENV['DB_STRUCTURE'] = config.dump_path.to_s
        Rake::Task['db:structure:dump'].invoke
      end

      def load_command
        raise NotImplementedError
      end

      def recreate_db
        ['db:drop', 'db:create'].each do |t|
          logger.info("Running\n\trake #{t}")
          Rake::Task[t].invoke
        end
      end
    end
  end
end
