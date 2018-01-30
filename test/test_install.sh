#!/usr/bin/env bash

### test_install.sh - test Modular Apache httpd configuration installation
###                   which is got from
###                   https://github.com/vvvggg/httpd-config and deployed
###                   (most likely) with its deploy/deploy.sh

# Exit immediately on any errors, using an unset var is error
# `-o pipefail' is commented because we want to know all the tests result
#set -Eeuo pipefail
set -Eeu

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

# Library functions
source "lib/test_func.sh"

# Configuration defaults
source "lib/test_conf.sh"



### Test definitions
### Define tests here

## Test 1
req_names=( "config file read" )  # Test name in the output
req_cmds=(  "file"             )  # Command to run
req_opts=(  "$config_file"     )  # The last option to be _double-quoted_ and
                                  # concatenated in the core with the command
                                  # to run
req_resps=( "ASCII text"       )  # Bash Regex. Command output expected to match

## Test 2
req_names+=( "Apache configtest"  )
req_cmds+=(  "httpd -d .. -t -f"  )
req_opts+=(      "$config_file_httpd" )
req_resps+=( "Syntax OK"          )

## Test 3
req_names+=( "logs directory writable"                 )
apache_user=`httpd_config_get_var "apache_user"`
log_dir=`    httpd_config_get_var "log_dir"`
req_cmds+=(  "sudo -u $apache_user sh -c"              )
req_opts+=(  "touch $log_dir/test && rm $log_dir/test" )
req_resps+=( "^$"                                      )

## Test 4
req_names+=( "docs root dir read"         )
document_root=` httpd_config_get_var "document_root"`
req_cmds+=(  "sudo -u $apache_user ls -a" )
req_opts+=(  "$document_root"             )
req_resps+=( "\.\."                       )

### /Test definitions


# Main logic
# Should be the last code part due to exits are there
source "lib/test_core.sh"
