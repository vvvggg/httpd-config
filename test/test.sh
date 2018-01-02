#!/bin/bash

set -Eeuo pipefail

# full test
echo '>>> '`date "+%Y-%m-%d %H:%M:%S %Z"`
./test_install.sh        &&\
## CentOS-specific
systemctl restart httpd  &&\
## /CentOS-specific
./test_running.sh        &&\
./test_custom.sh         &&\
echo SUCCESS.
echo '<<< '`date "+%Y-%m-%d %H:%M:%S %Z"`
