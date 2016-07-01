# Change Log

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
