#!/usr/bin/env bash

set -x

rm -rf /etc/docker/daemon.json
rm -rf /etc/docker/*.pem
rm -rf /etc/systemd/system/docker.service.d
systemctl daemon-reload
