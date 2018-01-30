#!/usr/bin/env bash

### test_conf.sh  - a 'library' file to be included into test scripts.
###                 Describing defaults common for all the tests.

# Presuming the following file hierarchy:
#    ...
#      |-conf
#      |    `-...
#      |-deploy
#      |    `-...
#      |-test
#      |    |-lib
#      |    |   |-test_core.sh
#      |    |   `...`             <- we're here
#      |    |-test*.sh
#      |    `-...
#      .


## Configuration defaults for tests

# Main httpd configuration file
config_file="../conf/httpd.conf"
