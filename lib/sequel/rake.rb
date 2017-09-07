# frozen_string_literal: true

require_relative "rake/version"

module Sequel
  #
  # @example
  #   Sequel::Rake.configure do
  #     set :connection, ENV["DATABASE_URL"]
  #     set :migrations, "#{__dir__}/lib/db/migrations"
  #     set :namespace, "db"
  #   end
  #
  module Rake
    class << self
      def configuration
        @configuration ||= {
          connection: ENV["DATABASE_URL"],
          migrations: "db/migrations",
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
        value = configuration.fetch(key)
        return value.call if value.respond_to?(:call)
        value
      end

      def load!
        load "#{__dir__}/rake/tasks.rake"
      end
    end
  end
end
