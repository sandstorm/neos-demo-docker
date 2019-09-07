#!/bin/bash

set -ex

echo "Preparing Neos ..."
cd /app

# start postgres
/usr/lib/postgresql/11/bin/postgres -D /etc/postgresql/11/main/ &
sleep 3

cp /Settings.yaml /app/Configuration/
rm -Rf Data/Temporary

./flow doctrine:migrate
./flow site:import Neos.Demo
./flow resource:publish

./flow user:create ${ADMIN_USER:-admin} ${ADMIN_PASSWORD:-password} Admin Admax
./flow user:addrole ${ADMIN_USER:-admin} Neos.Neos:Administrator

./flow cache:warmup

# start nginx
nginx &


exec /usr/local/sbin/php-fpm