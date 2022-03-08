#!/bin/bash

GRAFANA_BINARY_NAME=grafana-enterprise-8.3.6-1.x86_64.rpm

wget https://dl.grafana.com/enterprise/release/$GRAFANA_BINARY_NAME
sudo yum install $GRAFANA_BINARY_NAME

rm -rf $GRAFANA_BINARY_NAME

sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
sudo systemctl enable grafana-server.service