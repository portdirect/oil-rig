#!/bin/bash
set -x

/usr/bin/dockerd --storage-driver=overlay2
