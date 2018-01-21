# vg.'s httpd-config
Modular Apache httpd configuration.

Created especially for quick and pre-configured Apache deployment across Linux/FreeBSD. Pre-configuration is picked as basic as possible, however with common best practices in mind.

By default includes two virtual hosts with common `DocumentRoot` directory: HTTP Virtualhost at `localhost:80` with unconditional redirect to the second 'work' HTTPS Virtualhost at `localhost:443`.

Some well-tested configuration examples/snippets are included. FCGId module is included as well.

## Deployment

  1. Download deployment script: `curl -fsSL https://raw.githubusercontent.com/vvvggg/httpd-config/master/deploy/deploy.sh > /tmp/deploy.sh`
  2. Update `/tmp/deploy.sh` Configuration defaults up to your needs: `domain_name`, `server_admin`, `document_root`, maybe `ssl_*` as well.
  3. Run `sudo bash /tmp/deploy.sh`
  4. Place at `$document_root` whatever you want
  5. Enjoy or rise a GitHub issue

**deploy.sh generates a PLAIN private key and 'blank' 3-year self-signed X.509 SSL certificate at /etc/ssl by default**

Backups the previous configuration with `.ORIG` suffix.

Main configuration parameters (aka constants) are described at `conf/httpd.conf`.

## Docker

To build a Docker image `httpd-config-test` and run a container `apache-test` based on it, you can do:

```
curl -fsSL https://raw.githubusercontent.com/vvvggg/httpd-config/master/docker/Dockerfile > /tmp/Dockerfile
docker build --no-cache=true -t httpd-config-test /tmp/
docker run -d --name apache-test -p 80:80 -p 443:443 httpd-config-test
curl -ksSL localhost
```

## Tests

In general, you can use `curl -ksSL localhost` to get the result of the default `httpd-config` deployment, however, there is more covered automation:

use `test/test.sh` for complete out-of-the-box tests run and `test/test_custom.sh` for your own ones.

Successfully last tested with:
 * Apache httpd 2.4.18-2ubuntu3.5 on Ubuntu 16.04.3 LTS
 * Apache httpd 2.4.6-67.el7.centos.6 on CentOS 7.4
 * Apache httpd 2.4.29 on FreeBSD 11.1-RELEASE-p6
 * Apache httpd 2.4.18 on Docker 17.12.0-ce with ubuntu:16.04
 
