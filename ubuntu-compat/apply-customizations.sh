#!/bin/bash
#
# Script to 'Ubuntu-ize' the official, Debian-based, httpd:2.2 image from Docker Hub
#
# This is largely to assist as a drop-in replacement for downstream images based on our older Ubuntu 12.04 release.
# Debian includes the same suite of packages but they're geared towards Apache 2.4.
# Note that we could do this all in the Dockerfile, if we wanted to have a ridiculous number of layers.
#
# Initial list of items pulled from 'dpkg-query -L' against apache2-utils, apache2.2-common on old
# Ubuntu 12.04 dtr.cucloud.net/cs/apache22 image.  We probably could have simply tried to force installation of
# those packages without dependencies on the newer image, either live by adding the 'precise' sources to apt and
# running 'apt-get download; dpkg -i', but encoding the bits we need seems like a better option.
#

BASEDIR=$(dirname "${0}")

echo "Applying Debian/Ubuntu branding from ${BASEDIR}."

set -e -x 

cp -p ${BASEDIR}/etc/apache2.init /etc/init.d/apache2
cp -p ${BASEDIR}/etc/apache2.default /etc/default/apache2

cp -rp ${BASEDIR}/apache2 /etc/
cd /etc/apache2/mods-enabled
for I in alias.conf alias.load auth_basic.load authn_file.load authz_default.load authz_groupfile.load authz_host.load authz_user.load autoindex.conf autoindex.load cuwebauth.load deflate.conf deflate.load dir.conf dir.load env.load log_config.load logio.load mime.conf mime.load negotiation.conf negotiation.load proxy.conf proxy.load proxy_http.load reqtimeout.conf reqtimeout.load rewrite.load setenvif.conf setenvif.load ssl.conf ssl.load status.conf status.load; do
    ln -s ../mods-available/${I}
done

cd /etc/apache2/sites-enabled
ln -s ../sites-available/default 000-default

install -d -g root -m 0755 -o root /usr/lib/apache2 /usr/lib/cgi-bin /usr/share/apache2 /var/www
install -d -g www-data -m 0755 -o www-data /var/cache/apache2 /var/cache/apache2/mod_disk_cache
install -d -g root -m 0750 -o root /var/log/apache2

ln -s /usr/local/apache2/modules /usr/lib/apache2/

for I in build error icons; do
    ln -s /usr/local/apache2/${I} /usr/share/apache2/${I}
done
cp -p ${BASEDIR}/helper-utils/ask-for-passphrase /usr/share/apache2/
ln -s /usr/local/apache2/htdocs /usr/share/apache2/default-site


cp -p ${BASEDIR}/helper-utils/a2enmod /usr/sbin/
for I in a2dismod a2dissite a2ensite; do
    ln -s /usr/sbin/a2enmod /usr/sbin/${I}
done

for I in ab dbmmanage htdbm htdigest htpasswd logresolve; do
    ln -s /usr/local/apache2/bin/${I} /usr/bin/${I}
done

for I in checkgid htcacheclean httxt2dbm rotatelogs; do
    ln -s /usr/local/apache2/bin/${I} /usr/sbin/${I}
done

# Instead of linking, we'll pull in our copy of Ubuntu's apachectl script
# to ensure the proper envvars logic is used.
#ln -s /usr/local/apache2/bin/apachectl /usr/sbin/apache2ctl
cp -p ${BASEDIR}/helper-utils/apache2ctl /usr/sbin/
ln -s /usr/sbin/apache2ctl /usr/sbin/apachectl

cp -p /usr/local/apache2/htdocs/index.html /var/www/

echo "Debian/Ubuntu branding complete"
