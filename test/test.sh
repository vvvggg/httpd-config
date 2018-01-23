#!/usr/bin/env bash


### test.sh - run all tests for the Modular Apache httpd configuration which is
###           got from https://github.com/vvvggg/httpd-config


# Presuming the following file hierarchy:
#    ...
#      |-conf
#      |    |-Includes
#      |    |-modules.d
#      |    |-httpd.conf
#      |    `-...
#      |-test
#      |    |-test*.sh
#      |    `-...           <- we're here
#      |-deploy
#      |    `-...
#      .

# Exit immediately on any errors, using an unset var is error
set -Eeuo pipefail
umask 022

# Library functions
source "lib/test_func.sh"


## Test'em all
## Run all the tests in pipe:
./test_install.sh  &&\
httpd_restart      &&\
./test_runtime.sh  &&\
./test_custom.sh
## /Test

# Success only if all the previous tests are exited with 0
if [[ $? -eq 0 ]]; then
  echo SUCCESS.
  echo_start_mark
  exit 0
else
  echo FAIL.
  echo_finish_mark
  # 47 exit codes [79..125] are compatible for cross-platform custom usage
  exit 79
fi
