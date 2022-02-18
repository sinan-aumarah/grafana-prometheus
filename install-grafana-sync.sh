#!/bin/bash

GRAFANA_SYNC_ARTIFACT=grafana-sync_1.4.5_Linux_x86_64.tar.gz
## Reference https://github.com/mpostument/grafana-sync#push-dashboards
wget https://github.com/mpostument/grafana-sync/releases/download/1.4.5/$GRAFANA_SYNC_ARTIFACT
tar -xvf $GRAFANA_SYNC_ARTIFACT

sudo cp grafana-sync /usr/local/bin

rm -rf $GRAFANA_SYNC_ARTIFACT

EXTRACTED_API_KEY=$(curl 'http://localhost:3000/api/auth/keys' -XPOST -uadmin:admin -H 'Content-Type: application/json' -d '{"role":"Admin","name":"my-auto-key"}' | \
 python3 -c "import sys, json; print(json.load(sys.stdin)['key'])")

echo "Extracted API KEY $EXTRACTED_API_KEY"

export GRAFANA_API_KEY="$EXTRACTED_API_KEY"