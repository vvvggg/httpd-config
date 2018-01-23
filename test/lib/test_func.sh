#!/usr/bin/env bash

### test_func.sh  - a 'library' file to be included into test scripts.
###                 Implementing some functions common for all the tests.

# Presuming the following file hierarchy:
#    ...
#      |-conf
#      |    `-...
#      |-deploy
#      |    `-...
#      |-test
#      |    |-lib
#      |    |   |-test_core.sh
#      |    |   `...              <- we're here
#      |    |-test*.sh
#      |    `-...
#      .

# Get named var/const ($1) value from the actual Apache httpd config
function httpd_config_get_var() {
  echo `
    httpd -S                         |\
    egrep 'Define:[[:space:]]*'$1'=' |\
    awk -F"$1=" "{print \\$2}"
  `
  # also see `httpd -D DUMP_VHOSTS -D DUMP_MODULES' output
}

function httpd_restart() {
  echo restarting httpd...

  # Check OS type/distro and restart Apache httpd accordingly
  case `uname -o; if [[ -f /etc/os-release ]]; then cat /etc/os-release; fi` in

    *CentOS*)
      systemctl restart httpd
    ;;

    *Ubuntu*)
      # fucking systemd stuff is buggy here...
      #systemctl restart apache2

      ## workaround:
      # standard stop
      apache2ctl stop
      # kill those processes remained after the standard stop cmd finished
      pkill --signal SIGKILL apache2 2>&1 > /dev/null
      # standard start
      apache2ctl start
      # let apache processes get up before the next (outer) command exec
      # might be increaesed on slow machines/huge httpd configs
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

# `date' command output format
date_fmt='+%Y-%m-%d %H:%M:%S %Z'

# outputs a start mark with invocation script name and timestamp like
#   >>> ./test.sh 2018-01-23 15:43:58 MSK
function echo_start_mark() {
  echo ">>> $0 "`date "$date_fmt"`
}

# outputs a finish mark with invocation script name and timestamp like
#   <<< ./test.sh 2018-01-23 15:43:58 MSK
function echo_finish_mark() {
  echo "<<< $0 "`date "$date_fmt"`
}
