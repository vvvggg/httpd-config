#!/usr/bin/env bash

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
config_file="../conf/httpd.conf"
# hack for `httpd -d ..' below
# need to fix though
config_file_httpd="conf/httpd.conf"


function get_const() {
  # get constant definition given by name (from the config)
  echo `
    httpd -S                   |\
    egrep 'Define:\s*'$1'='    |\
    awk -F"$1=" "{print \\$2}"
  `
  # see also httpd's -D DUMP_VHOSTS -D DUMP_MODULES
}

echo testing the installation ...

# Test 1
req_names=( "config file read" )  # test name in the output
req_cmds=(  "file"             )  # command to run
reqs=(      "$config_file"     )  # param to concatenate the command
req_resps=( "ASCII text"       )  # Bash Regex. Output expected to match

# Test 2
req_names+=( "Apache configtest"  )
req_cmds+=(  "httpd -d .. -t -f"  )
reqs+=(      "$config_file_httpd" )
req_resps+=( "Syntax OK"          )

# Test 3
apache_user=`   get_const "apache_user"`
log_dir=`       get_const "log_dir"`
logdirtest_cmd="sudo -u $apache_user touch"
req_names+=( "logs directory writable" )
req_cmds+=(  "$logdirtest_cmd"         )
reqs+=(      "$log_dir/test"           )
req_resps+=( "^$"                      )

# Test 4
document_root=` get_const "document_root"`
rootdirtest_cmd="sudo -u $apache_user ls -a"
req_names+=( "docs root dir read" )
req_cmds+=(  "$rootdirtest_cmd"   )
reqs+=(      "$document_root"     )
req_resps+=( "\.\."               )



### main logic, do not change

err_flag=false

# test'em all if $req_names set
if [[ -n ${req_names+x} ]]; then
  for i in `seq 0 $(( ${#req_names[@]} - 1 ))`; do

    echo -n "  $(( i + 1 ))/${#req_names[@]} test "
    echo -n "${req_names[$i]}... "

    response=`${req_cmds[$i]} ${reqs[$i]} 2>&1 | sort`

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
