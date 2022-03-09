#!/bin/sh

## Run in crontab to run every midnight
## 00 00 * * * path/to/update-remote.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

API_KEY=$GRAFANA_API_KEY
TARGET_DASHBOARDS_FOLDER="$SCRIPT_DIR/dashboards"
TARGET_GIT_BRANCH="auto-sync"
GRAFANA_URL="http://127.0.0.1:3000"
LOG_FILE="$SCRIPT_DIR/remote.log"

current_timestamp() {
  date +"at %H:%M:%S on %d/%m/%Y"
}

log() {
   timestamp=$(date "+%Y-%m-%d %H:%M:%S %Z")

   echo $1
   printf "[%s] $1\n" "$timestamp" >> "$LOG_FILE"
}

export_dashboards() {
  NUMBER_OF_GRAFANA_DASHBOARDS=0
  for dash in $(curl -sSL -k -H "Authorization: Bearer ${API_KEY}" "${GRAFANA_URL}/api/search?query=&" | jq -r '.[] | select(.type == "dash-db") | .uid'); do
    curl -sSL -k -H "Authorization: Bearer ${API_KEY}" "${GRAFANA_URL}/api/dashboards/uid/$dash" | jq -r . >${TARGET_DASHBOARDS_FOLDER}/${dash}.json

    # rename the exported dashboard to use slug rather than dashboard id
    slug=$(cat ${TARGET_DASHBOARDS_FOLDER}/${dash}.json | jq -r '.meta.slug')
    mv ${TARGET_DASHBOARDS_FOLDER}/${dash}.json "${TARGET_DASHBOARDS_FOLDER}/${slug}.json"

    # if we want to save the dashboards with their corresponding folder name
    #folder=$(cat ${TARGET_DASHBOARDS_FOLDER}/${dash}.json | jq -r '.meta.folderTitle')
    #mkdir -p "${TARGET_DASHBOARDS_FOLDER}/${folder}"
    #mv ${TARGET_DASHBOARDS_FOLDER}/${dash}.json "${TARGET_DASHBOARDS_FOLDER}/${folder}/${slug}.json"
    NUMBER_OF_GRAFANA_DASHBOARDS=$[$NUMBER_OF_GRAFANA_DASHBOARDS + 1]
  done

  log "Exporting done. Saved $NUMBER_OF_GRAFANA_DASHBOARDS dashboards"
}

clone_remote_repo_if_not_present() {
  ## clone project if not cloned already
  if [ ! -d "$TARGET_DASHBOARDS_FOLDER" ]
  then
    git clone -b "$TARGET_GIT_BRANCH" "$DASHBOARDS_GIT_REPO" "$TARGET_DASHBOARDS_FOLDER"
    git remote -v
  fi
}

push_to_remote() {
  cd "$TARGET_DASHBOARDS_FOLDER" || exit
  git add .
  git commit -am "auto-sync $(current_timestamp)"
  git push origin $TARGET_GIT_BRANCH
}


#### START OF SCRIPT EXECUTION #####

clone_remote_repo_if_not_present

export_dashboards

push_to_remote