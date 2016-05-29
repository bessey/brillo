module Brillo
  module Adapter
    class Postgres < Base
      def load_command
        "psql --host #{config[:host]} -U #{config[:username]} #{config[:password] ? "-W#{config[:password]}" : ""} #{config[:database]}"
      end
    end
  end
end
