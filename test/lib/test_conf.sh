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

# Hack for `httpd -d ..' at installatino Test2
# TODO: need to fix though
# this is how httpd see relative path to its config
# probably `httpd -d ...' should use `-f' flag in the test
config_file_httpd="conf/httpd.conf"
