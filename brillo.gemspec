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

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|example_app)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"
  spec.add_dependency "capistrano", "~> 3.0"
  spec.add_dependency "polo", "~> 0.4"
  spec.add_dependency "aws-sdk-s3", "~> 1"
  spec.add_dependency "activerecord",  ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "rspec-rails", "~> 5.1"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "benchmark-ips"
end
