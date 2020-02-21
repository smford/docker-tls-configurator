# docker-tls-configurator

A simple script that generates and configures TLS for docker, allowing you quickly and easily get it working.

Based upon this document: [Protect the Docker daemon socket](https://docs.docker.com/engine/security/https/)

Configures the right things to allow easy connection from [Portainer.io](https://www.portainer.io/)

## Tested on:
 - Ubuntu 18.04.3 LTS bionic

## Usage:
```
./configure-tls

A simple tool to configure TLS certificates for docker

Usage:
  configure-docker-tls <hostname> <ip>

 hostname = DNS hostname of server running the docker daemon
 ip       = IP address of server running the docker daemon
```
