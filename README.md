# vg.'s httpd-config
Modular Apache httpd configuration.

Main constants are described at `Includes/server/httpd.server.const.conf`

By default includes two virtual hosts: Virtualhost at `:80` with unconditional redirect to the second 'work' Virtualhost `:443`.

Last tested with Apache httpd 2.4.27 on FreeBSD 11.1-RELEASE-p6
