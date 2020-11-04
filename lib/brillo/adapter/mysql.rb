# frozen_string_literal: true

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
        password = config['password'] ? "-p#{config['password']}" : ''
        "mysql #{host} -u #{config.fetch('username')} #{password} #{config.fetch('database')}"
      end
    end
  end
end
