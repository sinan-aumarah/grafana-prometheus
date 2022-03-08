#!/bin/bash

sudo useradd --no-create-home prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

PROMETHEUS_VERSION=2.33.3
PROMETHEUS_PLATFORM=linux-amd64
PROMETHEUS_FULL_NAME=prometheus-$PROMETHEUS_VERSION.$PROMETHEUS_PLATFORM

wget  https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/$PROMETHEUS_FULL_NAME.tar.gz
tar -xvf $PROMETHEUS_FULL_NAME.tar.gz
sudo cp $PROMETHEUS_FULL_NAME/prometheus /usr/local/bin
sudo cp $PROMETHEUS_FULL_NAME/promtool /usr/local/bin
sudo cp -r $PROMETHEUS_FULL_NAME/consoles /etc/prometheus/
sudo cp -r $PROMETHEUS_FULL_NAME/console_libraries /etc/prometheus
sudo cp $PROMETHEUS_FULL_NAME/promtool /usr/local/bin/

rm -rf $PROMETHEUS_FULL_NAME.tar.gz
sudo cp prometheus.yml /etc/prometheus/
sudo cp prometheus.service /etc/systemd/system/prometheus.service

sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /var/lib/prometheus

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl status prometheus