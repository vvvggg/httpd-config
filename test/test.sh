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

function restart_httpd() {
  eecho restarting httpd...
  # Check OS type/distro and restart Apache httpd accordingly
  case `uname -o; if [[ -f /etc/os-release ]]; then cat /etc/os-release; fi` in
    *CentOS*)
      systemctl restart httpd
    ;;
    *Ubuntu*)
      # fu&^#%( systemd stuff might is buggy here...
      #systemctl restart apache2
      ## workaround:
      apache2 -k stop
      pkill --signal SIGKILL apache2 2>&1 > /dev/null
      apache2 -k start
      sleep 2
;;
    *FreeBSD*)
      service apache24 restart
    ;;
    *)
      echo -n "Don't know how to restart Apache in this OS, "
      echo    " skipping"
    ;;
  esac
  echo done.
}


echo ">>> $0 "`date "+%Y-%m-%d %H:%M:%S %Z"`


## Test
## Run all the tests in pipe: 
./test_install.sh  &&\
restart_httpd      &&\
./test_runtime.sh  &&\
./test_custom.sh
## /Test

# Success only if all the previous tests are exited with 0
if [[ $? -eq 0 ]]; then
  echo SUCCESS.
  echo "<<< $0 "`date "+%Y-%m-%d %H:%M:%S %Z"`
  exit 0
else
  echo FAIL.
  echo "<<< $0 "`date "+%Y-%m-%d %H:%M:%S %Z"`
  # 47 exit codes [79..125] are compatible for cross-platform custom usage
  exit 79
fi
