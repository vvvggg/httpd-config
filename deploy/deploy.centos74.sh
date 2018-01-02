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

# directory containing all the conf/, deploy/, test/, ... dirs
conf_predir=/etc/httpd

ssl_cert_dir=/etc/ssl

# these consts should match httpd.conf ones
conf_dir=$conf_predir/conf
domain_name=localhost
apache_user=apache
apache_group=apache
log_dir=/var/log/httpd
ssl_key=$ssl_cert_dir/privkey.pem
ssl_cert=$ssl_cert_dir/$domain_name.pem
document_root=/var/www/virtual/$domain_name

## CentOS-specific
# our minimal suite
yum -y install httpd mod_ssl mod_fcgid git bash
systemctl enable httpd
## /CentOS-specific


# config dir
mv $conf_predir $conf_predir.ORIG
mkdir -p $conf_predir

# get the tested template config
git clone https://github.com/vvvggg/httpd-config $conf_predir/

mkdir -pm 770 $log_dir
chgrp $apache_group $log_dir

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

## CentOS-specific
# by default those are closed with CentOS firewall
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

# fu^$#&% systemd penetration, CentOS
cat >> $conf_dir/httpd.conf <<EOD
LoadModule  systemd_module  \${mod_dir}/mod_systemd.so
EOD
## /CentOS-specific

# test/run/test
../test/test.sh






