# frozen_string_literal: true

module Brillo
  module Dumper
    class MysqlDumper
      include Helpers::ExecHelper
      include Logger
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def dump
        db = config.db
        execute!(
          'mysqldump',
          host_arg,
          "-u #{db['username']}",
          password_arg,
          '--no-data',
          '--single-transaction', # InnoDB only. Prevent MySQL locking the whole database during dump.
          (db['database']).to_s,
          "> #{config.dump_path}"
        )
      end

      private

      def password_arg
        password = config.db['password'].presence
        return '' if password.blank?

        "--password=#{password}"
      end

      def host_arg
        host = config.db['host'].presence
        return '' if host.blank? || host == 'localhost'

        "-h #{host}"
      end
    end
  end
end
