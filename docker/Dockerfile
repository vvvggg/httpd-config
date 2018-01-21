FROM  ubuntu

RUN  apt-get update -qy; \
     # sudo is needed by deploy.sh:test.:test_install.sh
     apt-get install -qy sudo bash

ADD  [ "https://raw.githubusercontent.com/vvvggg/httpd-config/master/deploy/deploy.sh", \
       "/tmp/deploy.sh" ]
RUN  bash /tmp/deploy.sh

EXPOSE  80 443

CMD  ["apache2", "-D", "FOREGROUND", "-f", "/etc/apache2/apache2.conf"]

