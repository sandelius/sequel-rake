# frozen_string_literal: true

module Sequel
  #
  # @example
  #   Sequel::Rake.configure do
  #     set :connection, ENV["DATABASE_URL"]
  #     set :migrations, "#{__dir__}/lib/db/migrations"
  #   end
  #
  module Rake
    # Current version number.
    VERSION = '0.0.1'

    class << self
      def configuration
        @configuration ||= {,
          connection: ENV["DATABASE_URL"],
          migrations: "db/migrations"
        }
      end

      def configure(&block)
        instance_eval(&block)
      end

      def set(key, value)
        @configuration[key, value]
      end

      def get(key)
        @configuration.fetch(key)
      end
    end
  end
end
