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
  echo restarting httpd...
  # Check OS type/distro and restart Apache httpd accordingly
  case `uname -o; if [[ -f /etc/os-release ]]; then cat /etc/os-release; fi` in
    *CentOS*)
      systemctl restart httpd
    ;;
    *Ubuntu*)
      # fu&^#%( systemd stuff might is buggy here...
      #systemctl restart apache2
      ## workaround:
      
            echo "===> DEBUG: Active Apache httpd processes (/bin/ps -ef | egrep apache):"
        /bin/ps -ef | egrep apache
      echo "===> DEBUG: /Active Apache httpd processes (/bin/ps -ef | egrep apache):"
      echo "===> DEBUG: Listening activities (/bin/ss -nlp | egrep '(:80)|(:443)'):"
        /bin/ss -nlp | egrep '(:80)|(:443)'
      echo "===> DEBUG: /Listening activities (/bin/ss -nlp | egrep '(:80)|(:443)'):"




      echo "===> DEBUG: Stopping Apache httpd:"
        apache2 -k stop
      echo "===> DEBUG: /Stopping Apache httpd:"

      echo "===> DEBUG: Active Apache httpd processes (/bin/ps -ef | egrep apache):"
        /bin/ps -ef | egrep apache
      echo "===> DEBUG: /Active Apache httpd processes (/bin/ps -ef | egrep apache):"
      echo "===> DEBUG: Listening activities (/bin/ss -nlp | egrep '(:80)|(:443)'):"
        /bin/ss -nlp | egrep '(:80)|(:443)'
      echo "===> DEBUG: /Listening activities (/bin/ss -nlp | egrep '(:80)|(:443)'):"


      echo "===> DEBUG: Killing Apache httpd remnants, if any:"
        pkill   apache2 2>&1 > /dev/null
      echo "===> DEBUG: /Killing Apache httpd remnants, if any:"





      echo "===> DEBUG: Active Apache httpd processes (/bin/ps -ef | egrep apache):"
        /bin/ps -ef | egrep apache
      echo "===> DEBUG: /Active Apache httpd processes (/bin/ps -ef | egrep apache):"
      echo "===> DEBUG: Listening activities (/bin/ss -nlp | egrep '(:80)|(:443)'):"
        /bin/ss -nlp | egrep '(:80)|(:443)'
      echo "===> DEBUG: /Listening activities (/bin/ss -nlp | egrep '(:80)|(:443)'):"

      echo "===> DEBUG: Starting Apache httpd:"
        apache2 -k start
        sleep 2
      echo "===> DEBUG: /Starting Apache httpd:"

      echo "===> DEBUG: Active Apache httpd processes (/bin/ps -ef | egrep apache):"
        /bin/ps -ef | egrep apache
      echo "===> DEBUG: /Active Apache httpd processes (/bin/ps -ef | egrep apache):"
      echo "===> DEBUG: Listening activities (/bin/ss -nlp | egrep '(:80)|(:443)'):"
        /bin/ss -nlp | egrep '(:80)|(:443)'
      echo "===> DEBUG: /Listening activities (/bin/ss -nlp | egrep '(:80)|(:443)'):"

      
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


## Test
## Run all the tests in pipe: success only if all are exited 0
./test_install.sh  &&\
restart_httpd      &&\
./test_runtime.sh  &&\
./test_custom.sh   &&\
echo SUCCESS.
## /Test

echo '<<< '`date "+%Y-%m-%d %H:%M:%S %Z"`


exit 0
