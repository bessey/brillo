# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'brillo/version'

Gem::Specification.new do |spec|
  spec.name          = "brillo"
  spec.version       = Brillo::VERSION
  spec.authors       = ["Matt Bessey"]
  spec.email         = ["mbessey@caring.com"]

  spec.summary       = %q{Rails database scrubber and loader, great for seeding your dev db with real but sanitized data}
  spec.homepage      = "https://github.com/bessey/brillo"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://gems.caring.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|dummy)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "capistrano", "~> 3.0"
  spec.add_runtime_dependency "polo", "~> 0.3"

  spec.add_development_dependency "rails", ">= 3.2"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "benchmark-ips"
  spec.add_development_dependency "geminabox"
end
