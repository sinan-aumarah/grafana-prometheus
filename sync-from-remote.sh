#!/bin/bash

## USAGE: nohup ./sync-from-remote.sh > sync.log 2>&1 &
TARGET_BRANCH="rsync"
SYNC_DIR="dashboards"
SYNC_INTERVAL_IN_SECONDS=30
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

## export env variable for the actual git repository
git clone -b $TARGET_BRANCH $DASHBOARDS_GIT_REPO $SYNC_DIR

function sync_dashboards {
  while true
  do
    git -C ./$SYNC_DIR pull origin $TARGET_BRANCH
    ## make sure to export grafana API key (admin) as GRAFANA_API_KEY
    "$SCRIPT_DIR"/grafana-sync push-dashboards --apikey=$GRAFANA_API_KEY --directory="dashboards" --url http://127.0.0.1:3000

    sleep $SYNC_INTERVAL_IN_SECONDS
  done
}

sync_dashboards

