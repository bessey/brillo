# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'brillo/version'

Gem::Specification.new do |spec|
  spec.name          = "brillo"
  spec.version       = Brillo::VERSION
  spec.authors       = ["Matt Bessey"]
  spec.email         = ["mbessey@caring.com"]

  spec.summary       = %q{Opinionated Rails scrubber}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "capistrano", "~> 3.0"
  spec.add_runtime_dependency "polo"

  spec.add_development_dependency "rails", ">= 3.2"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "benchmark-ips"
end
