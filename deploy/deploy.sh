#!/bin/bash

set -Eeuo pipefail
umask 022

# presuming the following file hierarchy:
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


## Configuration defaults based on those for CentOS 7
httpd_cmd=httpd
# directory containing all the conf/, deploy/, test/, ... dirs
conf_predir=/etc/httpd
conf_file=httpd.conf
# these consts below should match httpd.conf ones
conf_dir=conf
log_dir=/var/log/httpd
apache_user=apache
apache_group=apache
mod_dir=/usr/lib64/httpd/modules
domain_name=localhost
server_admin="webmaster@${domain_name}"
document_root=/var/www/html
ssl_key=/etc/ssl/privkey.pem
ssl_cert=/etc/ssl/$domain_name.pem
## /Configuration defaults


# Check OS type/distro and update all the consts above accordingly
case `uname -o; if [[ -f /etc/os-release ]]; then cat /etc/os-release; fi` in
  *CentOS*)
    # $os var will be used later
    os="centos"
  ;;
  *Ubuntu*)
    os="ubuntu"
    httpd_cmd=apache2
    conf_predir=/etc/apache2
    conf_file=apache2.conf
    apache_user=www-data
    apache_group=www-data
    mod_dir=/usr/lib/apache2/modules
    log_dir=/var/log/apache2
  ;;
  *FreeBSD*)
    os="freebsd"
    conf_predir=/usr/local/etc/apache24
    conf_file=httpd.conf
    apache_user=www
    apache_group=www
    mod_dir=/usr/local/libexec/apache24
    log_dir=/var/log/apache24
  ;;
  *)
    os="other"
  ;;
esac

# force installation of our minimal suite
case $os in
  centos)
    yum -y install httpd mod_ssl mod_fcgid git bash curl
    systemctl enable httpd
    # by default those are closed by CentOS firewall
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --reload
  ;;
  ubuntu)
    apt-get -y install apache2 libapache2-mod-fcgid git bash curl
    # Ubuntu has `apache2' binary instead of `httpd', but
    # httpd is needed to be ok for our test scripts
    ln -fs `which apache2` `dirname \`which apache2\``/httpd
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

# config dir
rm -rf "$conf_predir.ORIG"
mv "$conf_predir" "$conf_predir.ORIG"
mkdir -p "$conf_predir"

# get the tested template config
git clone -b devel https://github.com/vvvggg/httpd-config $conf_predir/

# make config location distro-compatible (no needed for CentOS though)
ln -fs $conf_predir/$conf_dir/httpd.conf $conf_predir/$conf_file

# httpd.conf configuration definitions substitution
sed -i.ORIG -r -e "                                                       \
s%^(\s*ServerRoot\s+).*%\1\"${conf_predir}\"%;                            \
s%^(\s*Define\s+conf_dir\s+).*%\1\"${conf_dir}\"%;                        \
s%^(\s*Define\s+log_dir\s+).*%\1\"${log_dir}\"%;                          \
s%^(\s*Define\s+server_incdir\s+).*%\1\"\${conf_dir}/Includes/server\"%;  \
s%^(\s*Define\s+apache_user\s+).*%\1\"${apache_user}\"%;                  \
s%^(\s*Define\s+apache_group\s+).*%\1\"${apache_group}\"%;                \
s%^(\s*Define\s+mod_dir\s+).*%\1\"${mod_dir}\"%;                          \
s%^(\s*Define\s+domain_name\s+).*%\1\"${domain_name}\"%;                  \
s%^(\s*Define\s+server_admin\s+).*%\1\"${server_admin}\"%;                \
s%^(\s*Define\s+document_root\s+).*%\1\"${document_root}\"%;              \
s%^(\s*Define\s+ssl_key\s+).*%\1\"${ssl_key}\"%;                          \
s%^(\s*Define\s+ssl_cert\s+).*%\1\"${ssl_cert}\"%                         \
" $conf_predir/$conf_dir/httpd.conf

# log dir
mkdir -pm 770 $log_dir
chgrp $apache_group $log_dir
chmod g+rwx $log_dir

# generate self-signed cert (and the orivate key)
# RSA:   -newkey rsa:4096
# ECDSA: -newkey ec -pkeyopt ec_paramgen_curve:prime256v1
# see man req(1) for details
openssl req                        \
  -newkey rsa:4096                 \
  -keyout $ssl_key                 \
  -new    -x509 -days 1095 -nodes  \
  -subj   "/C=XX\
/ST=\
/L=\
/O=\
/OU=\
/CN=${domain_name}\
/emailAddress=${server_admin}"     \
  -out    $ssl_cert                2>&1 > /dev/null
chmod 600 $ssl_key $ssl_cert

# web dir
mkdir -pm 750 $document_root
chgrp $apache_group $document_root

# test file. For deploy/debug/test purposes only. To be replaced in prod.
cp $conf_predir/test/index.html $document_root/

# post-scripts
case $os in
  centos)
    # fu^$#&% systemd penetration, CentOS
    egrep -c '^\s*LoadModule\s+systemd_module' \
      $conf_predir/$conf_dir/httpd.conf > /dev/null ||\
    cat >> $conf_predir/$conf_dir/httpd.conf <<EOD
LoadModule  systemd_module  \${mod_dir}/mod_systemd.so
EOD
  ;;
  ubuntu)
    if [[ -f $conf_predir.ORIG/envvars ]]; then
      cp -af $conf_predir.ORIG/envvars $conf_predir/envvars
    else
      cp -f  $conf_predir/deploy/envvars.ubuntu $conf_predir/envvars
    fi
    chown $apache_user:adm $log_dir
    chmod g=rwx $log_dir
  ;;
esac
## /post-scripts

# test/run/test
cd ${conf_predir}/test
./test.sh
