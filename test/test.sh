#!/bin/bash

#set -Eeuo pipefail
set -Eeu

function restart_httpd() {
  echo restarting httpd...
  # Check OS type/distro
  case `uname -o; cat /etc/os-release` in
    *CentOS*)
      systemctl restart httpd
    ;;
    *Ubuntu*)
      systemctl restart apache2
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

echo '>>> '`date "+%Y-%m-%d %H:%M:%S %Z"`

# full test
./test_install.sh  &&\
restart_httpd      &&\
./test_running.sh  &&\
./test_custom.sh   &&\
echo SUCCESS.

echo '<<< '`date "+%Y-%m-%d %H:%M:%S %Z"`
