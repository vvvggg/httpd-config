#!/usr/bin/env bash

### deploy.sh - deploy Modular Apache httpd configuration which will be
###             downloaded from https://github.com/vvvggg/httpd-config

# Exit immediately on any errors incl. in pipes, using an unset var is error
set -Eeuo pipefail
umask 022

# Presuming the following file hierarchy:
#    ...
#      |-conf
#      |    |-Includes
#      |    |-modules.d
#      |    |-httpd.conf
#      |    `-...
#      |-test
#      |    |-test*.sh
#      |    `-...
#      |-deploy
#      |    `-...           <- we're here
#      .


## Custom vars
## edit these vars up to your needs;
## the default ones are ok for localhost with self-signed SSL cert

# Virtual host domain name (e.g. example.com, localhost, etc.);
# should be resolvable via DNS/hosts
domain_name="localhost"

# Virtual host root directory (all the data should be placed there)
document_root="/var/www/html"

# The whole server admin contact
server_admin="webmaster@${domain_name}"

# WARNING: update the following ssl_* vars to prevent
#          your existing files overwrite, if any

# openssl PLAIN private key to be generated
ssl_key="/etc/ssl/privkey.pem"

# X.509 SSL self-signed certificate to be generated
ssl_cert="/etc/ssl/${domain_name}.pem"

# Public access dir
#pub_dir="${document_root}/pub"

## /Custom vars


## Configuration defaults
## DO NOT EDIT unless you're absolutely sure
## Based on those for CentOS 7

# Apache httpd executable
httpd_cmd="httpd"

# Directory containing all the conf/, deploy/, test/, ... dirs
conf_predir="/etc/httpd"

# Main configuration file name
conf_file="httpd.conf"

# NOTE: the following var names should match those in the main configuration
#       file (i.e. httpd.conf by default) definitions

# Directory containing all the configuration files/dirs
conf_dir="conf"

# Apache httpd user and group names
apache_user="apache"
apache_group="apache"

# Directory containing all the Apache httpd module files (i.e. mod_*.so)
mod_dir="/usr/lib64/httpd/modules"

# Directory containing all the log files
log_dir="/var/log/httpd"

# File type icons dir
icons_dir="/usr/share/httpd/icons"

## /Configuration defaults


echo ">>> $0"

# Check OS type/distro and update all the vars defined above accordingly
case `uname -o; if [[ -f /etc/os-release ]]; then cat /etc/os-release; fi` in
  *CentOS*)
    # $os var will be used later
    os="centos"
  ;;
  *Ubuntu*)
    os="ubuntu"
    httpd_cmd="apache2"
    conf_predir="/etc/apache2"
    conf_file="apache2.conf"
    apache_user="www-data"
    apache_group="www-data"
    mod_dir="/usr/lib/apache2/modules"
    log_dir="/var/log/apache2"
    icons_dir="/usr/share/apache2/icons"
  ;;
  *FreeBSD*)
    os="freebsd"
    conf_predir="/usr/local/etc/apache24"
    conf_file="httpd.conf"
    apache_user="www"
    apache_group="www"
    mod_dir="/usr/local/libexec/apache24"
    log_dir="/var/log/apache24"
    icons_dir="/usr/local/www/apache24/icons"
  ;;
  *)
    os="other"
  ;;
esac

# Install our dependencies: Apache with some modules, git, etc.
case $os in
  centos)
    yum -y install httpd mod_ssl mod_fcgid git bash curl
    systemctl enable httpd
    # open TCP 80,443 permanently in firewall: they are closed by default
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --reload
  ;;
  ubuntu)
    apt-get -y install apache2 libapache2-mod-fcgid git bash curl
    # Ubuntu has `apache2' binary instead of `httpd', but
    # `httpd' is needed to be ok for our test scripts
    # therefore symlink if apache2 exists
    apache_cmd=`which apache2`
    if [[ $apache_cmd =~ ^\s*/ ]]; then
      ln -fs "${apache_cmd}" "`dirname ${apache_cmd}`/httpd"
    fi
  ;;
  freebsd)
    pkg install -y apache24 ap24-mod_fcgid git bash curl
    echo 'apache24_enable="YES"' >> /etc/rc.conf
  ;;
  *)
    echo -n "Don't know how to install Apache httpd and modules on this OS, "
    echo    "skipping"
  ;;
esac

# Config dir: backup the original, create the new one
# WARNING: deletes prevoius backup
rm -rf "${conf_predir}.ORIG"
mv "$conf_predir" "${conf_predir}.ORIG"
mkdir -p "$conf_predir"

# get the tested default httpd-config release
git clone https://github.com/vvvggg/httpd-config $conf_predir/
# DEBUG: instead of git clone
#cp -Rf .. "$conf_predir"

# Make the main config file location distro-compatible
# (no needed for CentOS though)
ln -fs "${conf_predir}/${conf_dir}/httpd.conf" "${conf_predir}/${conf_file}"

# The main config file (httpd.conf by default) configuration definitions
# substitution with the configuration vars defined above, making backup of the
# original config
sed -i.ORIG -r                                                                                            \
  -e "s%^([[:space:]]*ServerRoot[[:space:]]+).*%\1\"${conf_predir}\"%"                                    \
  -e "s%^([[:space:]]*Define[[:space:]]+conf_dir[[:space:]]+).*%\1\"${conf_dir}\"%"                       \
  -e "s%^([[:space:]]*Define[[:space:]]+log_dir[[:space:]]+).*%\1\"${log_dir}\"%"                         \
  -e "s%^([[:space:]]*Define[[:space:]]+server_incdir[[:space:]]+).*%\1\"\${conf_dir}/Includes/server\"%" \
  -e "s%^([[:space:]]*Define[[:space:]]+apache_user[[:space:]]+).*%\1\"${apache_user}\"%"                 \
  -e "s%^([[:space:]]*Define[[:space:]]+apache_group[[:space:]]+).*%\1\"${apache_group}\"%"               \
  -e "s%^([[:space:]]*Define[[:space:]]+mod_dir[[:space:]]+).*%\1\"${mod_dir}\"%"                         \
  -e "s%^([[:space:]]*Define[[:space:]]+domain_name[[:space:]]+).*%\1\"${domain_name}\"%"                 \
  -e "s%^([[:space:]]*Define[[:space:]]+server_admin[[:space:]]+).*%\1\"${server_admin}\"%"               \
  -e "s%^([[:space:]]*Define[[:space:]]+document_root[[:space:]]+).*%\1\"${document_root}\"%"             \
  -e "s%^([[:space:]]*Define[[:space:]]+ssl_key[[:space:]]+).*%\1\"${ssl_key}\"%"                         \
  -e "s%^([[:space:]]*Define[[:space:]]+ssl_cert[[:space:]]+).*%\1\"${ssl_cert}\"%"                        \
  "${conf_predir}/${conf_dir}/httpd.conf"

# Log dir adjustment
mkdir -pm 770 "$log_dir"
chgrp $apache_group "$log_dir"
chmod g+rwx "$log_dir"

# DocumentRoot dir
mkdir -pm 750 "$document_root"
chgrp $apache_group "$document_root"

# Icons dir
# will be linked to $pub_dir/icons if $pub_dir defined
if [ -z ${pub_dir+x} ]; then
  ln -fs "$icons_dir" "${pub_dir}/icons"
fi

## SSL cert
# Generate the private key and 3-year self-signed X.509 SSL cert
# WARNING: there are very test-like cert fields values used
#          like for `C' (Country), need to customize in prod,
#          see man openssl(1) or, in brief,
#          https://gusev.pro/SSLTips#Self-signed_SSL_cert
# INFO: example encryption options:
#       RSA:   -newkey rsa:4096
#       ECDSA: -newkey ec -pkeyopt ec_paramgen_curve:prime256v1
#       see man req(1) for details
openssl req                        \
  -newkey rsa:4096                 \
  -keyout "$ssl_key"               \
  -new    -x509 -days 1095 -nodes  \
  -subj   "/C=XX\
/ST=\
/L=\
/O=\
/OU=\
/CN=${domain_name}\
/emailAddress=${server_admin}"     \
  -out    "$ssl_cert"              2>/dev/null
chmod 600 "$ssl_key" "$ssl_cert"
## /SSL cert


## Post-scripts

# Some distro-dependant post-scripts
case $os in
  centos)
    # add load module for fucking systemd support
    egrep -c '^[[:space:]]*LoadModule[[:space:]]+systemd_module' \
      "${conf_predir}/${conf_dir}/httpd.conf" > /dev/null ||\
    cat >> ${conf_predir}/${conf_dir}/httpd.conf <<EOD
LoadModule  systemd_module  "\${mod_dir}/mod_systemd.so"
EOD
  ;;
  ubuntu)
    # Ubuntu has to have several environment variables set before
    # successful Apache httpd start attempt, all in one `envvars' file
    if [[ -f "${conf_predir}.ORIG/envvars" ]]; then
      cp -af "${conf_predir}.ORIG/envvars" "${conf_predir}/envvars"
    else
      cp -f  "${conf_predir}/deploy/envvars.ubuntu" "${conf_predir}/envvars"
    fi
  ;;
esac

# Comment `SSLSessionTickets off' uncommented directive
# for httpd early versions (<2.4.12) everywhere within the config dir
# backing up with '.ORIG' files
httpd_ver=`httpd -v | grep version | sed -r \
             -e 's/.*Apache\/2\.([[:digit:]]+)\.([[:digit:]]+).*/2\1\2/'`
if [[ $httpd_ver -lt 2412 ]]; then
  matched_files=`egrep  -RIils                                          \
                       '^[[:space:]]*SSLSessionTickets[[:space:]]+off'  \
                       "${conf_predir}/${conf_dir}"/*`
  for file in $matched_files; do
    sed -i.ORIG -r                                                  \
      -e "s%^([[:space:]]*SSLSessionTickets[[:space:]]+off.*)%#\1%" \
      "$file"
  done
fi
## /Post-scripts


## Tests run
cd "${conf_predir}/test"

# Copy test HTML/SSI file as index.html for this test only
cp "index.test.html" "${document_root}/index.html"

./test.sh || (
  echo "<<< $0"
  exit 80
)

# Leave renamed test index file secured by .htaccess for further possible tests
cp "${document_root}/index.html" "${document_root}/index.test.html"
cp ".htaccess.test" "${document_root}/.htaccess"

## /Tests

echo "<<< $0"
exit 0





### P.S.
# automated testing inotify-based example:
# $ while inotifywait -rq -e modify ~/tmp/share/httpd-config; do ( time vagrant provision www2 www3 www4 | grep SUCCESS ); echo '<<< '`date "+%Y-%m-%d %H:%M:%S %Z"`; echo; echo; done
