#!/bin/bash

## USAGE: nohup ./auto-sync.sh > sync.log 2>&1 &

SYNC_INTERVAL_IN_SECONDS=60

while true
do

  ./update-remote.sh

  ./sync-from-remote.sh

  sleep $SYNC_INTERVAL_IN_SECONDS
done