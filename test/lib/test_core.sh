#!/usr/bin/env bash

### test_core.sh  - a 'library' file to be included into test scripts.
###                 Implementing main logic MUST be common for all the tests.

# Presuming the following file hierarchy:
#    ...
#      |-conf
#      |    `-...
#      |-deploy
#      |    `-...
#      |-test
#      |    |-lib
#      |    |   |-test_core.sh    <- we're here
#      |    |   `...`
#      |    |-test*.sh
#      |    `-...
#      .


## Main logic
## DO NOT EDIT unless you're absolutely sure

err_flag=false

# test'em all if $req_names set
if [[ -n ${req_names+x} ]]; then
  for i in `seq 0 $(( ${#req_names[@]} - 1 ))`; do

    echo -n "  $(( i + 1 ))/${#req_names[@]} test "
    echo -n "${req_names[$i]}... "

    response=`${req_cmds[$i]} "${req_opts[$i]}" 2>&1 | LC_ALL=C sort`

    if [[ ${response} =~ ${req_resps[$i]} ]]; then
      echo passed.
    else
      echo failed.
      err_flag=true
    fi

done
fi
echo done.

# Is any of tests failed?
if [[ $err_flag == true ]]; then
  # 47 exit codes [79..125] are compatible for cross-platform custom usage
  exit 79
fi

# Otherwise, all tests are passed
exit 0


## /Main logic
