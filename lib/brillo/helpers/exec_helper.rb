require 'open3'
module Brillo
  module Helpers
    module ExecHelper
      def execute(*command)
        command_string = Array(command).join(' ')
        log_anonymized command_string
        stdout, stderr, status = Open3.capture3 command_string
        [status.success?, stdout, stderr]
      end

      def execute!(*command)
        success, stdout, stderr = execute(command)
        if success
          [success, stdout, stderr]
        else
          raise RuntimeError, "#{stdout} #{stderr}"
        end
      end

      private

      def log_anonymized(command_string)
        command_string = command_string.gsub(/MYSQL_PWD=[^\s]+/, 'MYSQL_PWD={FILTERED}')
        command_string = command_string.gsub(/PGPASSWORD=[^\s]+/, 'PGPASSWORD={FILTERED}')
        command_string = command_string.gsub(/--password=[^\s]+/, '--password={FILTERED}')
        command_string = command_string.gsub(/EC2_ACCESS_KEY=[^\s]+/, 'EC2_ACCESS_KEY={FILTERED}')
        command_string = command_string.gsub(/EC2_SECRET_KEY=[^\s]+/, 'EC2_SECRET_KEY={FILTERED}')
        logger.info "Running \n\t #{command_string}"
      end
    end
  end
end
