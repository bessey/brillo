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
          "mysqldump",
          host_arg,
          "-u #{db[:username]}",
          password_arg,
          "--no-data",
          "--single-transaction", # InnoDB only. Prevent MySQL locking the whole database during dump.
          "#{db[:database]}",
          "> #{config.dump_path}"
        )
      end

      private

      def password_arg
        if password = config.db[:password].presence
          "--password=#{password}"
        else
          ""
        end
      end

      def host_arg
        if (host = config.db[:host].presence) && host != 'localhost'
          "-h #{host}"
        else
          ""
        end
      end
    end
  end
end
