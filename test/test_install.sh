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


## Configuration defaults
## DO NOT EDIT unless you're absolutely sure

# Main configuration file
config_file="../conf/httpd.conf"

# Hack for `httpd -d ..' at Test2 below
# TODO: need to fix though
config_file_httpd="conf/httpd.conf"

## /Configuration defaults

# Get named var/const ($1) value from the actual Apache httpd config
function get_var() {
  echo `
    httpd -S                         |\
    egrep 'Define:[[:space:]]*'$1'=' |\
    awk -F"$1=" "{print \\$2}"
  `
  # also see `httpd -D DUMP_VHOSTS -D DUMP_MODULES' output
}



### Test definitions
### Define tests here

## Test 1
req_names=( "config file read" )  # test name in the output
req_cmds=(  "file"             )  # command to run
reqs=(      "$config_file"     )  # param to concatenate the command
req_resps=( "ASCII text"       )  # Bash Regex. Output expected to match

## Test 2
req_names+=( "Apache configtest"  )
req_cmds+=(  "httpd -d .. -t -f"  )
reqs+=(      "$config_file_httpd" )
req_resps+=( "Syntax OK"          )

## Test 3
req_names+=( "logs directory writable"     )
apache_user=`get_var "apache_user"`
log_dir=`    get_var "log_dir"`
req_cmds+=(  "sudo -u $apache_user touch"  )
reqs+=(      "$log_dir/test"               )
req_resps+=( "^t$"                          )

## Test 4
req_names+=( "docs root dir read"         )
document_root=` get_var "document_root"`
req_cmds+=(  "sudo -u $apache_user ls -a" )
reqs+=(      "$document_root"             )
req_resps+=( "\.\."                       )

### /Test definitions


## Main logic
## DO NOT EDIT unless you're absolutely sure

echo running installation tests...
err_flag=false

# test'em all if $req_names set
if [[ -n ${req_names+x} ]]; then
  for i in `seq 0 $(( ${#req_names[@]} - 1 ))`; do

    echo -n "  $(( i + 1 ))/${#req_names[@]} test "
    echo -n "${req_names[$i]}... "

    response=`${req_cmds[$i]} ${reqs[$i]} 2>&1 | LC_ALL=C sort`

    if [[ ${response} =~ ${req_resps[$i]} ]]; then
      echo passed.
    else
      echo failed.
      err_flag=true
    fi

done
fi
echo done.

# Clean up test remnants here, if any
rm -f "$log_dir/test"

# Is any of tests failed?
if [[ $err_flag == true ]]; then
  # 47 exit codes [79..125] are compatible for cross-platform custom usage
  exit 79
fi

## /Main logic


## All tests are passed
exit 0
