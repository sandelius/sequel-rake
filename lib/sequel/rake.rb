# frozen_string_literal: true

require_relative "rake/version"
require_relative "rake/migration_file"

module Sequel
  #
  # @example
  #   Sequel::Rake.configure do
  #     set :connection, ENV["DATABASE_URL"]
  #     set :migrations_dir, "#{__dir__}/lib/db/migrations"
  #     set :namespace, "db"
  #   end
  #
  module Rake
    class << self
      def configuration
        @configuration ||= {
          connection: ENV["DATABASE_URL"],
          migrations_dir: "db/migrations",
          namespace: "sequel"
        }
      end

      def configure(&block)
        instance_eval(&block)
      end

      def set(key, value)
        configuration[key] = value
      end

      def get(key)
        configuration.fetch(key)
      end

      def load!
        load "#{__dir__}/rake/tasks.rake"
      end
    end
  end
end
