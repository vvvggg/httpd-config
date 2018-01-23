#!/usr/bin/env bash

### test_func.sh  - a 'library' file to be included into test scripts.
###                 Implementing some functions common for all the tests.

# Exit immediately on any errors, using an unset var is error
# `-o pipefail' is commented because we want to know all the tests result
#set -Eeuo pipefail
set -Eeu

# Presuming the following file hierarchy:
#    ...
#      |-conf
#      |    `-...
#      |-deploy
#      |    `-...
#      |-test
#      |    |-lib
#      |    |   |-test_core.sh
#      |    |   `...              <- we're here
#      |    |-test*.sh
#      |    `-...
#      .

# Get named var/const ($1) value from the actual Apache httpd config
function get_var() {
  echo `
    httpd -S                         |\
    egrep 'Define:[[:space:]]*'$1'=' |\
    awk -F"$1=" "{print \\$2}"
  `
  # also see `httpd -D DUMP_VHOSTS -D DUMP_MODULES' output
}
 
