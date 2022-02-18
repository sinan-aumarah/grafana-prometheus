#!/bin/sh

## Run in crontab to run every midnight
## 00 00 * * * path/to/update-remote.sh

SYNC_DIR="sync_directory"
TARGET_BRANCH="rsync"

current_timestamp() {
  date +"at %H:%M:%S on %d/%m/%Y"
}

## clone project if not cloned already
if [ ! -d $SYNC_DIR ]
then
  git clone -b $TARGET_BRANCH $DASHBOARDS_GIT_REPO $SYNC_DIR
fi

grafana-sync pull-dashboards --apikey=$GRAFANA_API_KEY --directory="$SYNC_DIR" --url http://127.0.0.1:3000

cd $SYNC_DIR || exit
git add .
git commit -am "auto-sync $(current_timestamp)"
git push origin $TARGET_BRANCH
