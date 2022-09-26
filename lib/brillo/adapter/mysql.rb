module Brillo
  module Adapter
    class MySQL < Base
      def header
        super + <<-SQL
        -- Disable autocommit, uniquechecks, and foreign key checks, for performance on InnoDB
        -- http://dev.mysql.com/doc/refman/5.5/en/optimizing-innodb-bulk-data-loading.html
        SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, AUTOCOMMIT = 0;
        SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS = 0;
        SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;
        SQL
      end

      def footer
        super + <<-SQL
        SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
        SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
        SET AUTOCOMMIT = @OLD_AUTOCOMMIT;
        COMMIT;
        SQL
      end

      def dump_structure_and_migrations(config)
        Dumper::MysqlDumper.new(config).dump
      end

      def load_command
        host = config['host'] ? "--host #{config['host']}" : ''
        password = config['password'] ? "MYSQL_PWD='#{config['password']}' " : ''
        # If present, the database.yml url parameter should take precedence.
        if (url = config['url'])
          uri = URI.parse(url)
          password = uri.password ? "MYSQL_PWD='#{uri.password}' " : ''
          # We set the URI password component to nil because it's handled by the `-p` flag and will
          # be masked later on (see the `log_anonymized' method).
          uri.password = nil
          command_parameters = uri
        else
          command_parameters = "#{host} -u #{config.fetch('username')} #{config.fetch('database')}"
        end

        "#{password}mysql #{command_parameters}"
      end
    end
  end
end
