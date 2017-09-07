# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

require "bundler/setup"

if ENV["COVERAGE"] == "true"
  require "simplecov"
  require "codeclimate-test-reporter"

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter
  ])

  SimpleCov.start do
    command_name "test"
    add_filter   "test"
  end
end

require "minitest/autorun"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "sequel/rake"
