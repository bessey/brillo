module Brillo
  module Adapter
    class Postgres < Base
      def load_command
        host = config[:host] ? "--host #{config[:host]}" : ""
        password = config[:password] ? "PGPASSWORD=#{config[:password]} " : ""
        "#{password}psql #{host} -U #{config[:username]} #{password} #{config[:database]}"
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
    end
  end
end
