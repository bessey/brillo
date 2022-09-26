module Brillo
  module Adapter
    class Postgres < Base
      def load_command
        host = config["host"] ? "--host #{config["host"]}" : ""
        password = config["password"] ? "PGPASSWORD=#{config["password"]} " : ""
        search_path = config["schema_search_path"] ? "PGOPTIONS=--search_path=#{config["schema_search_path"]} " : ""

        # If present, the database.yml url parameter should take precedence.
        if url = config["url"]
          uri = URI.parse(url)
          password = uri.password
          uri.password = nil # We set the URI password component to nil because it's handled by the
                             # PGPASSWORD environment variable and will be masked later on (see the
                             # `log_anonymized' method).
          command_parameters = uri
        else
          command_parameters = "#{host} -U #{config.fetch("username")} #{config.fetch("database")}"
        end

        inline_options = password + search_path
        "#{inline_options}psql #{command_parameters}"
      end

      # pgdump without schema does not set sequences, so we have to do it ourselves, or the first insert
      # into a scrubbed table will fail on duplicate primary key
      def table_footer(klass)
        table_name = klass.table_name
        <<-SQL
          SELECT setval(pg_get_serial_sequence('#{table_name}', 'id'), coalesce(MAX(id),0) + 1, false)
          FROM #{table_name};
        SQL
      end

      def recreate_db
        logger.info "Dropping all connections to #{config[:database]}"
        ActiveRecord::Base.connection.execute(
          <<-SQL
          -- Disconnect all others from the database we are about to drop.
          -- Without this, the drop will fail and so the load will abort.
          SELECT pg_terminate_backend(pg_stat_activity.pid)
          FROM pg_stat_activity
          WHERE pg_stat_activity.datname = '#{config[:database]}'
            AND pid <> pg_backend_pid();
          SQL
        )
        super
      end
    end
  end
end
