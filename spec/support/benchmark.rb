# frozen_string_literal: true

require 'benchmark/ips'

RSpec.configure do |config|
  config.filter_run_excluding(perf: true) if ENV.key?('CI')
end
