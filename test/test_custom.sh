#!/usr/bin/env bash

### test_custom.sh - custom user tests for running Modular Apache httpd
###                  configuration which is got from
###                  https://github.com/vvvggg/httpd-config and deployed
###                  (most likely) with its deploy/deploy.sh
#
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


## Common vars for functional tests
domain_name=`  httpd_config_get_var "domain_name"  `
document_root=`httpd_config_get_var "document_root"`

# HTTPS by default is too easy :-), hence it's commented
#url="https://$domain_name"
# We want to test automatic HTTP -> HTTPS redirect as well, so start with HTTP
url="http://$domain_name"

# for just `/' our test /index.html by default will be got here (see
# deploy/deploy.sh for details)
# TODO: change to something like `index.test.html' with appropriate access
# rules, to give place for prod' one
uri="/"

## /Common vars for functional tests



### Test definitions


## Test 1
#req_names=( "HTTP GET ${url}${uri}" )  # Test name in the output
#req_cmds=(  "curl -kfsSSL"          )  # Command to run
#req_opts=(  "${url}${uri}"          )  # The last option to be
                                        # _double-quoted_ and concatenated with
                                        # The command to run
#req_users=( ""                      )  # User name to use like as req_opts
#req_psws=(  ""                      )  # The user password
#req_resps=( "DOCUMENT_ROOT="        )  # Bash Regex. Output expected to match


## Test 2
#req_names+=( "Apache configtest"  )
#req_cmds+=(  "httpd -d .. -t -f"  )
#req_opts+=(  "$config_file_httpd" )
#req_users+=( ""                   )
#req_psws+=(  ""                   )
#req_resps+=( "Syntax OK"          )


## Test 3
# req_names+=( "logs directory writable"                 )
# apache_user=`httpd_config_get_var "apache_user"`
# log_dir=`    httpd_config_get_var "log_dir"`
# req_cmds+=(  "sudo -u $apache_user sh -c"              )
# req_opts+=(  "touch $log_dir/test && rm $log_dir/test" )
# req_resps+=( "^$"                                      )

### /Test definitions


# Main logic
# Should be the last code part due to exits are there
source "lib/test_core.sh"
