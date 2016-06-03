module Brillo
  module Adapter
    class Postgres < Base
      def load_command
        host = config[:host] ? "--host #{config[:host]}" : ""
        password = config[:password] ? "-W#{config[:password]}" : ""
        "psql #{host} -U #{config[:username]} #{password} #{config[:database]}"
      end
    end
  end
end
