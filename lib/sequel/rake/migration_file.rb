# frozen_string_literal: true

module Sequel
  module Rake
    ## Migration file
    class MigrationFile
      MIGRATION_CONTENT =
        <<~STR
          # frozen_string_literal: true

          Sequel.migration do
            change do
            end
          end
        STR

      DISABLING_EXT = ".bak"

      class << self
        def find(query, only_one: true, enabled: true, disabled: true)
          filenames = Dir[File.join(migrations_dir, "*#{query}*")]
          filenames.select! { |filename| File.file? filename }
          files = filenames.map { |filename| new filename: filename }.sort!
          files.reject!(&:disabled) unless disabled
          files.select!(&:disabled) unless enabled
          return files unless only_one
          return files.first if files.size < 2
          raise "More than one file matches the query"
        end

        def migrations_dir
          Sequel::Rake.get(:migrations_dir)
        end
      end

      attr_accessor :version
      attr_reader :name, :disabled

      def initialize(filename: nil, name: nil)
        self.filename = filename
        self.name = name if name
      end

      ## Accessors

      def basename
        File.basename(@filename)
      end

      def filename=(value)
        parse_filename value if value.is_a? String
        @filename = value
      end

      def name=(value)
        @name = value.tr(" ", "_").downcase
      end

      def disabled=(value)
        @disabled =
          case value
          when String
            [DISABLING_EXT, DISABLING_EXT[1..-1]].include? value
          else
            value
          end
      end

      def <=>(other)
        version <=> other.version
      end

      ## Behavior

      def print
        datetime = DateTime.parse(version).strftime("%F %R")
        fullname = name.tr("_", " ").capitalize
        fullname = "#{fullname} (disabled)" if disabled
        version_color, name_color =
          disabled ? ["\e[37m", "\e[37m- "] : ["\e[36m", ""]
        puts "\e[37m[#{version}]\e[0m #{version_color}#{datetime}\e[0m" \
          " #{name_color}#{fullname}\e[0m"
      end

      def generate
        self.version = new_version
        FileUtils.mkdir_p File.dirname new_filename
        File.write new_filename, MIGRATION_CONTENT
      end

      def reversion
        rename version: new_version
      end

      def disable
        abort "Migration already disabled" if disabled
        rename disabled: true
      end

      def enable
        abort "Migration already enabled" unless disabled
        rename disabled: false
      end

      private

      def parse_filename(value = @filename)
        basename = File.basename value
        self.version, parts = basename.split("_", 2)
        self.name, _ext, self.disabled = parts.split(".")
      end

      def new_version
        Time.now.strftime("%Y%m%d%H%M")
      end

      def rename(vars = {})
        vars.each { |key, value| send :"#{key}=", value }
        return unless @filename.is_a? String
        File.rename @filename, new_filename
        self.filename = new_filename
      end

      def new_filename
        new_basename = "#{version}_#{name}.rb#{DISABLING_EXT if disabled}"
        File.join self.class.migrations_dir, new_basename
      end
    end
  end
end
