# frozen_string_literal: true

require_relative "lib/sequel/rake"

Gem::Specification.new do |spec|
  spec.name    = "sequel-rake"
  spec.version = Sequel::Rake::VERSION
  spec.summary = "Rake tasks for the Sequel gem."

  spec.required_ruby_version     = ">= 2.3.0"
  spec.required_rubygems_version = ">= 2.5.0"

  spec.license = "MIT"

  spec.author   = "Tobias Sandelius"
  spec.email    = "tobias@sandeli.use"
  spec.homepage = "https://github.com/sandelius/sequel-rake"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19"

  spec.add_development_dependency "sequel"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest", ">= 5.7.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "codeclimate-test-reporter"
end
