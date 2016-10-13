namespace :sequel do
  require "sequel"
  require "fileutils"

  desc "Creates the migrations directory"
  task :init do
    FileUtils::mkdir_p path(migrations)
  end

  desc "Generate a new migration file `sequel:generate[create_books]`"
  task :generate, :name do |_, args|
    name = args[:name]
    abort("Missing migration file name") if name.nil?

    content = "# frozen_string_literal: true\n\nSequel.migration do\n  change do\n    \n  end\nend\n"
    timestamp = Time.now.to_i
    filename = File.join(migrations, "#{timestamp}_#{name}.rb")

    File.write(filename, content)
  end

  desc "Migrate the database (you can specify the version with `db:migrate[N]`)"
  task :migrate, [:version] do |task, args|
    version = args[:version] ? Integer(args[:version]) : nil
    migrate(version)
  end

  desc "Undo all migrations and migrate again"
  task :remigrate do
    migrate(0)
    migrate
  end

  def migrate(version = nil)
    Sequel.extension :migration
    Sequel::Migrator.apply(connection, migrations, version)
  end

  def path(path)
    "#{Dir.pwd}/#{path}"
  end

  def connection
    @connection ||= Sequel.connect(Sequel::Rake.get(:connection))
  end

  def migrations
    Sequel::Rake.get(:migrations)
  end
end
