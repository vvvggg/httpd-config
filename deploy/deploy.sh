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
conf_file=httpd.conf
domain_name=localhost
apache_user=apache
apache_group=apache
server_admin="webmaster@${domain_name}"
mod_dir=/usr/lib64/httpd/modules
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
    mod_dir=/usr/lib64/httpd/modules
    log_dir=/var/log/httpd
  ;;
  *Ubuntu*)
    os="ubuntu"
    conf_predir=/etc/apache2
    conf_file=apache2.conf
    ln -s $conf_dir/httpd.conf $conf_predir/$conf_file
    apache_user=www-data
    apache_group=www-data
    mod_dir=/usr/lib/apache2/modules
    log_dir=/var/log/apache2
  ;;
  *FreeBSD*)
    os="freebsd"
    conf_predir=/usr/local/etc/apache24
    conf_file=httpd.conf
    ln -s $conf_dir/httpd.conf $conf_predir/$conf_file
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
git clone -b devel https://github.com/vvvggg/httpd-config $conf_predir/

# httpd.conf configuration definitions substitution


mkdir -pm 770 $log_dir
chgrp $apache_group $log_dir
chmod g+rwx $log_dir

# generate self-signed cert
#openssl genrsa -out $ssl_key 4096
# see man req(1) for details
openssl req                                                                    \
# -newkey ec -pkeyopt ec_paramgen_curve:prime256v1                             \
  -newkey rsa:4096                                                             \
  -keyout $ssl_key                                                             \
  -new    -x509 -days 1095 -nodes                                              \
  -subj   "/C=XX/ST=/L=/O=/OU=/CN=${domain_name}/emailAddress=${server_admin}" \
  -out    $ssl_cert
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
    cat >> $conf_dir/httpd.conf <<EOD
LoadModule  systemd_module  \${mod_dir}/mod_systemd.so
EOD
  ;;
esac
## /post-scripts

# test/run/test
cd ${conf_predir}/test
./test.sh
