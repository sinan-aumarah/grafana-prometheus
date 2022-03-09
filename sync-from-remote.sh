#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

## USAGE: nohup ./sync-from-remote.sh > sync.log 2>&1 &
TARGET_BRANCH="auto-sync"
SYNC_DIR="$SCRIPT_DIR/remote-sync-dashboards"
TARGET_HOST="127.0.0.1:3000"
SYNC_INTERVAL_IN_SECONDS=60

import_dashboards() {
  
  if [ -d "$SYNC_DIR" ]; then
      DASH_LIST=$(find "$SYNC_DIR" -mindepth 1 -name \*.json)
      if [ -z "$DASH_LIST" ]; then
          echo "Directory $SYNC_DIR contains no JSON files! make sure you cloned a branch with some dashboards"
          exit 1
      fi
  fi
  
  NUMBER_OF_SUCCESSFULL_IMPORTS=0
  NUMBER_OF_FAILURES=0
  COUNTER=0
  
  for DASH_FILE in $DASH_LIST; do
      COUNTER=$((COUNTER + 1))
      #echo "Importing $COUNTER/$FILESTOTAL: $DASH_FILE..."
      RESULT=$(cat "$DASH_FILE" | jq '. * {overwrite: true, dashboard: {id: null}}' | curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $GRAFANA_API_KEY" "http://$TARGET_HOST/api/dashboards/db" -d @-)
      if [[ "$RESULT" == *"success"* ]]; then
          # echo "$RESULT"
          NUMBER_OF_SUCCESSFULL_IMPORTS=$((NUMBER_OF_SUCCESSFULL_IMPORTS + 1))
      else
          echo "$RESULT"
          NUMBER_OF_FAILURES=$((NUMBER_OF_FAILURES + 1))
      fi
  done
  
  echo "Import complete. $NUMBER_OF_SUCCESSFULL_IMPORTS dashboards were successfully imported. $NUMBER_OF_FAILURES dashboard imports failed";
}


#### START OF SCRIPT EXECUTION #####

git clone -b $TARGET_BRANCH $DASHBOARDS_GIT_REPO $SYNC_DIR

cd "$SYNC_DIR" || exit

while true
do
  git fetch
  UPSTREAM=${1:-'@{u}'}
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "$UPSTREAM")
  BASE=$(git merge-base @ "$UPSTREAM")

  if [ $LOCAL = $REMOTE ]; then
      echo "No changes detected, Skipping import."
  elif [ $LOCAL = $BASE ]; then
      echo "Remote branch has been updated. Importing in progress..."

      git -C $SYNC_DIR pull

      import_dashboards
  fi

  sleep $SYNC_INTERVAL_IN_SECONDS
done


