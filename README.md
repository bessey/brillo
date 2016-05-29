# Brillo

Brillo is an opinionated ActiveRecord database scrubber + loader, that makes pulling light copies of your production DB easy as `rake db:load`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brillo'
```

And require the capistrano tasks by adding `require 'capistrano/brillo'` to your Capfile.

### Loading a database in development

```bash
$ ec2
$ rake db:load
```

### Loading a database on an edge

```bash
$ cap edge db:load
```

### Configuring a new app
Generate a starter `brillo.yml` file and `config/initializers/brillo.rb` with

```bash
$ rails g brillo_config
```

### Example brillo.yml for IMDB

```yaml
name: imdb            # Namespace the scrubbed file will occupy in S3
explore:
  user:               # Name of ActiveRecord class in snake_case
    tactic: all       # Scrubbing tactic to use (see Brillo:TACTICS for choices)
    associations:     # Associations to include in the scrub (ALL associated records included)
      - comments
  movie:
    tactic: latest    # The latest association explores the most recent 1,000 records
    associations:
      - actors
      - ratings
  admin/note:         # Corresponds to the Admin::Note class
    tactic: all
obfuscations:         #
  user.name: name     # Scrub user.name with the "name" scrubber (see Brillo::SCRUBBERS for choices)
  user.phone: phone
  user.email: email
```

### Adding scrub tactics and obfuscations

If the built in record selection tactics aren't enough for you, or you need a custom obfuscation strategy, you can add them via the initializer. They are available in the YAML config like any other strategy.

```ruby
# config/initializers/brillo.rb

Brillo.configure do |config|
  config.add_tactic :oldest, -> (klass) { klass.order(created_at: :desc).limit(1000) }

  config.add_obfuscation :remove_ls, -> (field) {
    field.gsub(/l/, "X")
  }

  # If you need the context of the entire record being obfuscated, it is available in the second argument
  config.add_obfuscation :phone_with_id, -> (field, instance) {
    (555_000_0000 + instance.id).to_s
  }
end

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
