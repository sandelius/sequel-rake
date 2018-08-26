# frozen_string_literal: true

namespace Sequel::Rake.get(:namespace) do
  require "sequel"
  require "fileutils"

  task :environment unless Rake::Task.task_defined?("sequel:environment")

  desc "Generate a new migration file"
  task :generate, [:name] => :environment do |_, args|
    name = args[:name]
    abort "You must specify a migration name" if name.nil?

    file = Sequel::Rake::MigrationFile.new name: name
    file.generate
  end
  alias_task :new, :generate

  desc "Change version of migration to latest"
  task :reversion, :filename do |_t, args|
    filename = args[:filename]
    abort "You must specify a migration name or version" if filename.nil?

    file = Sequel::Rake::MigrationFile.find filename
    file.reversion
  end

  desc "Disable migration"
  task :disable, :filename do |_t, args|
    filename = args[:filename]
    abort "You must specify a migration name or version" if filename.nil?

    file = Sequel::Rake::MigrationFile.find filename
    file.disable
  end

  desc "Enable migration"
  task :enable, :filename do |_t, args|
    filename = args[:filename]
    abort "You must specify a migration name or version" if filename.nil?

    file = Sequel::Rake::MigrationFile.find filename
    file.enable
  end

  desc "Show all migrations"
  task :list do |_t, _args|
    files = Sequel::Rake::MigrationFile.find "*", only_one: false
    files.each(&:print)
  end

  desc "Check applied migrations"
  task :check do
    applied_names = db_connection[:schema_migrations].select_map(:filename)
    applied =
      applied_names.map { |one| Sequel::Rake::MigrationFile.new filename: one }
    existing =
      Sequel::Rake::MigrationFile.find "*", only_one: false, disabled: false
    existing_names = existing.map(&:basename)
    a_not_e = applied.reject { |one| existing_names.include? one.basename }
    e_not_a = existing.reject { |one| applied_names.include? one.basename }
    if a_not_e.any?
      puts "Applied, but not existing"
      a_not_e.each(&:print)
      puts "\n" if e_not_a.any?
    end
    if e_not_a.any?
      puts "Existing, but not applied"
      e_not_a.each(&:print)
    end
    if a_not_e.empty? && e_not_a.empty?
      puts "All existing migrations are applied"
    end
  end

  desc "Migrate the database " \
       "(you can specify the versions with `db:migrate[target,current]`)"
  task :migrate, %i[target current] => :environment do |_task, args|
    migrate(args[:target], args[:current])
    puts "Migration complete"
  end
  alias_task :run, :migrate

  desc "Rollback the database N steps " \
       "(you can specify the version with `db:rollback[N]`)"
  task :rollback, [:step] => :environment do |_task, args|
    step = args[:step] ? Integer(args[:step]).abs : 1
    version = 0

    target_migration =
      connection[:schema_migrations]
        .reverse_order(:filename)
        .offset(step)
        .first
    if target_migration
      version = Integer(target_migration[:filename].match(/([\d]+)/)[0])
    end

    migrate(version)
    puts "Rollback complete"
    puts "Rolled back to version: #{version}"
  end

  desc "Undo all migrations and migrate again"
  task remigrate: :environment do
    migrate(0)
    migrate
    puts "Remigration complete"
  end

  def migrate(target = nil, current = nil)
    Sequel.extension :migration

    options = {}

    if target
      if target.to_s == "0"
        puts "Migrating all the way down"
      else
        file = Sequel::Rake::MigrationFile.find target, disabled: false
        abort "Migration with this version not found" if file.nil?
        current = args[:current] || "current"
        puts "Migrating from #{current} to #{file.basename}"
        target = file.version
      end
      options[:current] = args[:current].to_i
      options[:target] = target.to_i
    else
      puts "Migrating to latest"
    end

    connection.loggers << Logger.new($stdout)

    Sequel::Migrator.run(connection, migrations_dir, options)
  end

  def connection
    if Sequel::Rake.get(:connection).is_a?(Sequel::Database)
      Sequel::Rake.get(:connection)
    else
      @connection ||= Sequel.connect(Sequel::Rake.get(:connection))
    end
  end

  def migrations_dir
    Sequel::Rake.get(:migrations_dir)
  end

  def alias_task(name, original)
    t = Rake::Task[original]
    desc t.full_comment if t.full_comment
    task name, *t.arg_names do |_, args|
      # values_at is broken on Rake::TaskArguments
      args = t.arg_names.map { |a| args[a] }
      t.invoke(*args)
    end
  end
end
