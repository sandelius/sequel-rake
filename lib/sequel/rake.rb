# frozen_string_literal: true

module Sequel
  module Rake
    # Current version number.
    VERSION = '0.0.1'
  end
end

namespace :sequel do
  require 'sequel'
  require 'fileutils'
  require 'yaml'

  desc 'Creates a database.yml file'
  task :init do
    skeleton = "#{__dir__}/database.yml"

    if File.directory?(path('config'))
      FileUtils.cp(skeleton, path('config/database.yml'))
    else
      FileUtils.cp(skeleton, path('database.yml'))
    end

    FileUtils::mkdir_p path('db/migrations')
  end

  desc 'Generate a new migration file `sequel:generate[create_books]`'
  task :generate, :name do |_, args|
    name = args[:name]
    abort('Missing migration file name') if name.nil?

    content = "# frozen_string_literal: true\n\nSequel.migration do\n  change do\n    \n  end\nend\n"
    timestamp = Time.now.to_i
    filename = File.join(config[env]['migrations'], "#{timestamp}_#{name}.rb")

    File.write(filename, content)
  end

  desc 'Migrate the database (you can specify the version with `db:migrate[N]`)'
  task :migrate, [:version] do |task, args|
    version = args[:version] ? Integer(args[:version]) : nil
    migrate(version)
  end

  desc 'Undo all migrations and migrate again'
  task :remigrate do
    migrate(0)
    migrate
  end

  def migrate(version = nil)
    databases.each do |db|
      conn, opts = db
      Sequel.extension :migration
      Sequel::Migrator.apply(conn, opts['migrations'], version)
    end
  end

  def databases
    envs = []
    if env == 'production' || env == 'staging'
      envs << env
    else
      envs.concat(['development', 'test'])
    end
    envs.map { |e| [Sequel.connect(config[e]), config[env]] }
  end

  def path(path)
    "#{Dir.pwd}/#{path}"
  end

  def connection
    @connection ||= Sequel.connect(config)
  end

  def config
    @config ||= begin
      filepath = path('database.yml')

      unless File.exist?(filepath)
        filepath = path('config/database.yml')

        unless File.exist?(filepath)
          abort 'Missing database.yml file. Run `seqcli init` first'
        end
      end

      @config = YAML.load_file(filepath)
    end
  end

  def env
    ENV['RACK_ENV'] || 'development'
  end
end