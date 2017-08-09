# frozen_string_literal: true

namespace Sequel::Rake.get(:namespace) do
  require 'sequel'
  require 'fileutils'

  task :environment unless Rake::Task.task_defined?('sequel:environment')

  desc 'Creates the migrations directory'
  task init: :environment do
    FileUtils.mkdir_p migrations
    puts "generated: #{migrations}"
  end

  desc 'Generate a new migration file `sequel:generate[create_books]`'
  task :generate, [:name] => :environment do |_, args|
    name = args[:name]
    abort('Missing migration file name') if name.nil?

    content = <<~STR
      # frozen_string_literal: true

      Sequel.migration do
        change do
        end
      end
    STR

    timestamp = Time.now.to_i
    filename = File.join(migrations, "#{timestamp}_#{name}.rb")
    File.write(filename, content)
    puts "Generated: #{filename}"
  end

  desc 'Migrate the database (you can specify the version with `db:migrate[N]`)'
  task :migrate, [:version] => :environment do |_task, args|
    version = args[:version] ? Integer(args[:version]) : nil
    migrate(version)
    puts 'Migration complete'
  end

  desc 'Rollback the database N steps ' \
       '(you can specify the version with `db:rollback[N]`)'
  task :rollback, [:step] => :environment do |_task, args|
    step = args[:step] ? Integer(args[:step]) : 1
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
    puts 'Rollback complete'
    puts "Rolled back to version: #{version}"
  end

  desc 'Undo all migrations and migrate again'
  task remigrate: :environment do
    migrate(0)
    migrate
    puts 'Remigration complete'
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
