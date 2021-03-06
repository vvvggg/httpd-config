#!/usr/bin/env bash

### test_running.sh - test running Modular Apache httpd configuration
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


## Common vars for functional tests
domain_name=`  httpd_config_get_var "domain_name"  `
document_root=`httpd_config_get_var "document_root"`

# HTTPS by default is too easy :-), hence it's commented
#url="https://$domain_name"
# We want to test automatic HTTP -> HTTPS redirect as well, so start with HTTP
url="http://$domain_name"
uri="/"

## /Common vars for functional tests


## Test 1
req_names=( "Apache is running"                  )
function get_apache_proc_num() {
  # number of running `apache2' processes
  pgrep "(httpd)|(apache2)" | wc -l
}
req_cmds=(  "get_apache_proc_num"                )
req_opts=(  ""                                   )
req_users=( ""                                   )
req_psws=(  ""                                   )
req_resps=( "^[[:space:]]*([1-9][0-9]+)|([2-9])" )  # >1 (or 10+)


## Test 2
req_names+=( "HTTP GET ${url}${uri}" )  # Test name in the output
req_cmds+=(  "curl -kfsSL"           )  # Command to run
req_opts+=(  "${url}${uri}"          )  # The last option to be later
                                        # _double-quoted_ and concatenated in
                                        # the core with the command to run
req_users+=( ""                      )  # User name to use like as req_opts
req_psws+=(  ""                      )  # The user password
req_resps+=( "It works.+\
</html>.+\
<html.+\
DOCUMENT_ROOT=${document_root}.+\
REQUEST_URI=/.+\
SERVER_NAME=${domain_name}.+\
SSL_TLS_SNI=${domain_name}"          )  # Bash Regex. Output expected to match


## Test 3
#req_names+=( "Apache configtest"      )
#req_cmds+=(  "httpd -d ../conf -t -f" )
#req_opts+=(  "$config_file"           )
#req_users+=( ""                       )
#req_psws+=(  ""                       )
#req_resps+=( "Syntax OK"              )

### /Test definitions


# Main logic
# Should be the last code part due to exits are there
echo running runtime tests...
source "lib/test_core.sh"
