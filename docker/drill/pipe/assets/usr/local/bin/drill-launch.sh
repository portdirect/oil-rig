#!/bin/bash
set -x
docker-compose -f  /etc/oilrig/drill.yaml pull
docker-compose -f  /etc/oilrig/drill.yaml create
docker-compose -f  /etc/oilrig/drill.yaml start
docker-compose -f  /etc/oilrig/drill.yaml logs -f
