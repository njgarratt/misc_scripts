#!/bin/bash

ulimit -a

cd /data/Camera/Stills || exit 1

./todir.sh
./space.sh
nohup ./movies.sh &
