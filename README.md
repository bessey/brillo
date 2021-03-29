[![Gem Version](https://badge.fury.io/rb/brillo.svg)](https://badge.fury.io/rb/brillo)

# Brillo

Brillo is a Rails database scrubber and loader, useful for making lightweight copies of your production database for development machines, with sensitive information obfuscated. Most configuration is done through YAML: Specify the models that you want to back up, what associations you want with them, and what fields should be obfuscated (and how).

Once that is done, dropping your local DB and replacing it with the latest scrubbed copy is as easy as `rake db:load`.

Under the hood we use [Polo](https://github.com/IFTTT/polo) to explore the classes and associations you specify in brillo.yml, obfuscated fields as configured.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brillo'
```

Generate a starter `brillo.yml` file and `config/initializers/brillo.rb` with

```bash
$ rails g brillo_config
```

If you're using Capistrano, add Brillo's tasks to your Capfile:

```ruby
# Capfile
require 'capistrano/brillo'
```

Lastly, since the scrubber is pretty resource intensive you may wish to ensure it runs on separate hardware from your app servers:

```ruby
# config/deploy.rb
set :brillo_role, :my_batch_role
```

## Usage

Here's an example `brillo.yml` for IMDB:

```yaml
name: imdb # Namespace the scrubbed file will occupy in S3
compress: true # Compresses the file after scrubbing or not (default: true)
explore:
  user: # Name of ActiveRecord class in snake_case
    tactic: all # Scrubbing tactic to use (see Brillo:TACTICS for choices)
    associations: # Associations to include in the scrub (ALL associated records included)
      - comments
  movie:
    tactic: latest # The latest tactic explores the most recent 1,000 records
    associations:
      - actors
      - ratings
  admin/note: # Corresponds to the Admin::Note class
    tactic: all
obfuscations: #
  user.name: name # Scrub user.name with the "name" scrubber (see Brillo::SCRUBBERS for choices)
  user.phone: phone
  user.email: email
```

Brillo uses [the official aws-sdk](https://github.com/aws/aws-sdk-ruby) to communicate with S3. There [are a number of ways](https://github.com/aws/aws-sdk-ruby#configuration) to pass your S3 credentials, but the simplest is to set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in your environment.

If you'd like to see the gem in use, check out the [/example_app](https://github.com/bessey/brillo/tree/master/example_app) directory.

### Creating a scrubbed copy of the database in production

```bash
$ rake db:scrub
```

### Loading a database in development

```bash
$ rake db:load
```

### Loading a database on a stage

```bash
$ cap staging db:load
```

## Advanced Configuration

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

  # In addition to setting your S3 credentials via env you can set them something like this
  config.transfer_config.secret_access_key  = Rails.application.secrets.secret_access_key
  config.transfer_config.access_key_id      = Rails.application.secrets.access_key_id
end

```

## To Do

- Support alternative transfer mechanisms
