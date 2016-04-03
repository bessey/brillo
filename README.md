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
Generate a starter `brillo.yml` file with

```bash
$ rails g brillo_config
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
