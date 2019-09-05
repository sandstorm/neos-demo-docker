#!/bin/sh

set -e

echo "Prepairing Neos ..."
sleep 5

./flow doctrine:migrate
./flow site:import Neos.Demo
./flow resource:publish

./flow user:create admin password Admin Admax
./flow user:addrole admin Neos.Neos:Administrator

./flow cache:warmup
./flow server:run --host=0.0.0.0