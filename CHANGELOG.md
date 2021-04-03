# Change Log

## Unreleased

## 2.1.0

- Added `recreate_db` config option which:
  - Allows to skip dumping structures and migrations on Brillo.scrub!
  - Allows to skip db recreation on Brillo.load!
- Added `filename` scrub/load option to allow changing the name of the resulting scrubbed file or file to import on the DB.
- Added config option `schema_search_path` support for Postgres so you can specify the schema (if any) on your current pg db.
- Added `keep_local` param to Brillo.load to prevent downloading a file over and over again if the filename provided is already present. (useful for test runners)

## 2.0.0

Upgrade to AWS SDK 3.0, reduce dependence to S3 specifically.

Support ERB in brillo.yaml

Support alternative primary keys to "id"

Fix bug where Brillo breaks when using the Octopus gem

## 1.3.1

Disable query cacheing to reduce memory growth over time.

## 1.3.0

Remove Caring specific scrubber code

Fix Postgres load failing because of existing connection

## 1.2.2

Fixed initializer. `Brillo.configure` pre-initialization will now work.

Moved verification of config to post app initialization.

## 1.2.1

Support S3 config [via your environment](https://github.com/aws/aws-sdk-ruby#configuration). To configure via the environment, just leave your `Brillo.config.transfer_config.{access_key_id,secret_access_key}` blank.

## 1.1.4

Fix loading a postgres database with a password set.

## 1.1.3

Fix bug in S3 upload path. Files were previously uploading to their local system path in S3. I.e. `bucket-name/my/rails/app/tmp/my-app-scrubbed.dmp.gz`.

## 1.1.2

Set us-east-1 as the default region, because this is S3s default and can be accessed from other regions.

## 1.1.1

Fixed postgres sequence not being set to MAX(id).

## 1.1.0

**New**

- **BREAKING** Brillo used to support loading your credentials from a YAML file at `/etc/ec2_secure_env.yml`
  but no longer does. It is now your responsibility to ensure the credentials are in the environment Brillo
  runs in.
- Removed the dependency on the AWS Timkay CLI, instead using the AWS gem.
- Added support for configuring all S3 parameters in Ruby land

**Fixed**

- Fix mysql exec when no host specified
- Fix postgres exec when no host specified
- Fix postgres adapter reference

## 1.0.0

First public Brillo version!

## 0.3.0
