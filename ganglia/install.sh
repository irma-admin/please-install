#!/bin/bash

set -x 

cd /data/software/sources
mkdir ganglia
cd ganglia
wget https://sourceforge.net/projects/ganglia/files/ganglia-web/3.7.2/ganglia-web-3.7.2.tar.gz
tar xfz ganglia-web-3.7.2.tar.gz
mv ganglia-web-3.7.2 /var/www/ganglia2
cd /var/www/ganglia2
make install

cd /etc/apache2/sites-enabled/
ln -s /var/www/ganglia2/apache.conf

