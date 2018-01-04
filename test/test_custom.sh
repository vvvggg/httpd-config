#!/bin/bash

#set -Eeuo pipefail
set -Eeu

# presuming the following file hierarchy:
#    ...
#      |-conf
#      |    |-Includes
#      |    |-modules.d
#      |    |-httpd.conf
#      |    `-...
#      `-test
#           |-test*.sh      <- we're here
#           `-...
#

function get_const() {
  # get constant definition given by name (from the config)
  echo `
    httpd -S                   |\
    egrep 'Define:\s*'$1'='    |\
    awk -F"$1=" "{print \\$2}"
  `
  # see also httpd's -D DUMP_VHOSTS -D DUMP_MODULES
}

echo testing custom stuff ...

#domain_name=`   get_const "domain_name"`
#document_root=` get_const "document_root"`
##url="https://$domain_name"
#url="http://$domain_name"
#
## Test 1
#uri="/"
#req_names=( "HTTP GET ${url}${uri}" )  # test name in the output
#req_cmds=(  "curl -kfsSSL"          )  # command to run
#reqs=(      "${url}${uri}"          )  # param to concatenate the command
#req_users=( ""                      )  # user name to use similar to reqs
#req_psws=(  ""                      )  # the user password
#req_resps=( "DOCUMENT_ROOT="        )  # Bash Regex. Output expected to match
#
## Test 2
#req_names+=( "Apache configtest"  )
#req_cmds+=(  "httpd -d .. -t -f"  )
#reqs+=(      "$config_file_httpd" )
#req_users+=( ""                   )
#req_psws+=(  ""                   )
#req_resps+=( "Syntax OK"          )




### main logic, do not change

err_flag=false

# test'em all if $req_names set
if [[ -n ${req_names+x} ]]; then
  for i in `seq 0 $(( ${#req_names[@]} - 1 ))`; do

    echo -n "  $(( i + 1 ))/${#req_names[@]} test "
    echo -n "${req_names[$i]}... "

    response=`${req_cmds[$i]} ${reqs[$i]} | sort 2>&1`

    if [[ ${response} =~ ${req_resps[$i]} ]]; then
      echo passed.
    else
      echo failed.
      err_flag=true
    fi

  done
fi
echo done.

# clean up test remnants


# failed?
if [[ $err_flag == true ]]; then
  exit 1
fi

### /main logic



# passed
exit 0

