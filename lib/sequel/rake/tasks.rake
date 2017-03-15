namespace Sequel::Rake.get(:namespace) do
  require "sequel"
  require "fileutils"

  desc "Creates the migrations directory"
  task :init do
    FileUtils::mkdir_p migrations
    puts "generated: #{migrations}"
  end

  desc "Generate a new migration file `sequel:generate[create_books]`"
  task :generate, :name do |_, args|
    name = args[:name]
    abort("Missing migration file name") if name.nil?

    content = "# frozen_string_literal: true\n\nSequel.migration do\n  change do\n    \n  end\nend\n"
    timestamp = Time.now.to_i
    filename = File.join(migrations, "#{timestamp}_#{name}.rb")
    File.write(filename, content)
    puts "Generated: #{filename}"
  end

  desc "Migrate the database (you can specify the version with `db:migrate[N]`)"
  task :migrate, [:version] do |task, args|
    version = args[:version] ? Integer(args[:version]) : nil
    migrate(version)
    puts "Migration complete"
  end

  desc "Rollback the database N steps (you can specify the version with `db:rollback[N]`"
  task :rollback, [:step] do |task, args|
    step = args[:step] ? Integer(args[:step]) : 1
    version = 0

    if row = connection[:schema_migrations].order(Sequel.desc(:filename)).offset(step).first
      version = Integer(row[:filename].match(/([\d]+)/)[0])
    end

    migrate(version)
    puts "Rollback complete"
    puts "Rolled back to version: #{version}"
  end

  desc "Undo all migrations and migrate again"
  task :remigrate do
    migrate(0)
    migrate
    puts "Remigration complete"
  end

  def migrate(version = nil)
    Sequel.extension :migration
    Sequel::Migrator.apply(connection, migrations, version)
  end

  def connection
    @connection ||= Sequel.connect(Sequel::Rake.get(:connection))
  end

  def migrations
    Sequel::Rake.get(:migrations)
  end
end
