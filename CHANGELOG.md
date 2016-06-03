# Change Log

## 1.1.0
Removed the dependency on the AWS Timkay CLI, instead using the AWS gem.

**BREAKING** Brillo used to support loading your credentials from a YAML file at `/etc/ec2_secure_env.yml`
but no longer does. It is now your responsibility to ensure the credentials are in the environment Brillo
runs in.


## 1.0.0
First public Brillo version!

## 0.3.0
