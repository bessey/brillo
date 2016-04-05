# Brillo

Brillo is an opinionated ActiveRecord database scrubber + loader, that makes pulling light copies of your production DB easy as `rake db:load`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brillo'
gem 'polo', github: 'IFTTT/polo' # we rely on edge Polo till they cut a new gem
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
Generate a starter `brillo.yml` file with

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
    tactic: latest    # The latest assocation explores the most recent 1,000 records
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
