#!/bin/bash

#set -Eeuo pipefail
set -Eeu

function restart_httpd() {
  echo restarting httpd...
  # Check OS type/distro
  case `uname -o; if [[ -f /etc/os-release ]]; then cat /etc/os-release; fi` in
    *CentOS*)
      systemctl restart httpd
    ;;
    *Ubuntu*)
      # fu&^#%( systemd stuff is still buggy here...
      #systemctl restart apache2
      apache2 -k stop
      pkill   apache2 2>&1 > /dev/null
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

echo '>>> '`date "+%Y-%m-%d %H:%M:%S %Z"`

# full test
./test_install.sh  &&\
restart_httpd      &&\
./test_running.sh  &&\
./test_custom.sh   &&\
echo SUCCESS.

echo '<<< '`date "+%Y-%m-%d %H:%M:%S %Z"`
