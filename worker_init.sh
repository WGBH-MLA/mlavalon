#!/bin/bash

cd /home/app/avalon
export HOME=/home/app

nohup apt-get -y install dumb-init &
