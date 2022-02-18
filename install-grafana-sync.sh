#!/bin/bash

GRAFANA_SYNC_ARTIFACT=grafana-sync_1.4.5_Linux_x86_64.tar.gz
## Reference https://github.com/mpostument/grafana-sync#push-dashboards
wget https://github.com/mpostument/grafana-sync/releases/download/1.4.5/$GRAFANA_SYNC_ARTIFACT
tar -xvf $GRAFANA_SYNC_ARTIFACT

sudo cp grafana-sync /usr/local/bin

rm -rf $GRAFANA_SYNC_ARTIFACT