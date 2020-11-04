# frozen_string_literal: true

module Brillo
  # Responsible for asserting that the config file is valid
  class Scrubber
    include Common

    attr_reader :config

    def initialize(config)
      parse_config(config)
    end

    def validate
      errors = Hash.new({}.freeze)
      klass_association_map.each do |klass, options|
        begin
          deserialize_class(klass)
        rescue StandardError
          errors[klass][:name] = "No such class #{klass.camelize}, did you use the singular?"
        end

        begin
          tactic = options.fetch('tactic').to_sym
        rescue KeyError
          errors[klass][tactic] = 'Tactic not specified'
        end
      end
    end

    def deserialize_class(klass)
      klass.camelize.constantize
    end
  end
end
