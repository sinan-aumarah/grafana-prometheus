#!/bin/bash

## Reference https://github.com/mpostument/grafana-sync#push-dashboards
wget https://github.com/mpostument/grafana-sync/releases/download/1.4.5/grafana-sync_1.4.5_Linux_x86_64.tar.gz
tar -xvf grafana-sync_1.4.5_Linux_x86_64.tar.gz

git clone git@github.com:atl-mk/Jira-DC-Grafana-Dashabords.git dashboards

## make sure to export grafana API key (admin) as GRAFANA_API_KEY
grafana-sync push-dashboards --apikey=$GRAFANA_API_KEY --directory="dashboards" --url http://127.0.0.1:3000