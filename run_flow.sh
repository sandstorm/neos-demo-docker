#!/bin/sh

echo "Prepairing Neos ..."
sleep 5

./flow doctrine:migrate
./flow site:import Neos.Demo
./flow resource:publish
./flow cache:warmup
./flow server:run