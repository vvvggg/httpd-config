#!/bin/sh

set -Eeuo pipefail

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
conf_predir=/etc/httpd
# these consts below should match httpd.conf ones
ssl_cert_dir=/etc/ssl
conf_dir=$conf_predir/conf
domain_name=localhost
apache_user=apache
apache_group=apache
log_dir=/var/log/httpd
ssl_key=$ssl_cert_dir/privkey.pem
ssl_cert=$ssl_cert_dir/$domain_name.pem
document_root=/var/www/html
## /Configuration defaults


# Check OS type/distro
case `uname -o; cat /etc/os-release` in
  *CentOS*)
    # $os var will be used later
    os="centos"
    # directory containing all the conf/, deploy/, test/, ... dirs
    conf_predir=/etc/httpd
    apache_user=apache
    apache_group=apache
    log_dir=/var/log/httpd
  ;;
  *Ubuntu*)
    os="ubuntu"
    conf_predir=/etc/apache2
    apache_user=www-data
    apache_group=www-data
    log_dir=/var/log/apache2
  ;;
  *FreeBSD*)
    os="freebsd"
    conf_predir=/usr/local/etc/apache24
    apache_user=www
    apache_group=www
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
    #systemctl enable httpd
  ;;
  freebsd)
    pkg -y install apache24 ap24-mod_fcgid git bash curl
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
git clone https://github.com/vvvggg/httpd-config $conf_predir/

mkdir -pm 770 $log_dir
chgrp $apache_group $log_dir
chmod g+rwx $log_dir

# generate self-signed cert
openssl genrsa -out $ssl_key 4096
chmod 600 $ssl_key
openssl req -new -x509 -key $ssl_key -out $ssl_cert -days 1095
chmod 600 $ssl_cert

# web dir
mkdir -pm 750 $document_root
chgrp $apache_group $document_root

# test file. For deploy/debug/test purposes only. To be replaced in prod.
cp $conf_predir/test/index.html $document_root/

# post-scripts
case $os in
  centos)
    # fu^$#&% systemd penetration, CentOS
    cat >> $conf_dir/httpd.conf <<EOD
LoadModule  systemd_module  \${mod_dir}/mod_systemd.so
EOD
  ;;
esac
## /post-scripts

# test/run/test
cd ${conf_predir}/test
./test.sh
