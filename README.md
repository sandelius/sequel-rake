# sequel-rake

Provides useful rake tasks when working with the awesome Sequel gem.

The `database.yml` must be located at `./database.yml` or `./config/database.yml` in
order to be located.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel-rake'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel-rake

## Usage

```ruby
# Rakefile

require 'sequel/rake'
```

```
$ bundle exec rake ...

sequel:generate[name]   # Generate a new migration file `sequel:generate[create_books]`
sequel:init             # Creates a database.yml file
sequel:migrate[version] # Migrate the database (you can specify the version with `db:migrate[N]`)
sequel:remigrate        # Undo all migrations and migrate again
```

## TODO

* Rollback to previous version
* Write some tests

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sandelius/sequel-rake. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).