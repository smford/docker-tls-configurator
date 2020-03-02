# docker-tls-configurator

A simple script that generates and configures TLS for docker, allowing you quickly and easily get it working.

Based upon this document: [Protect the Docker daemon socket](https://docs.docker.com/engine/security/https/)

Configures the right things to allow easy connection from [Portainer.io](https://www.portainer.io/)

## Tested on

 - Ubuntu 18.04.3 LTS bionic

## Instructions

Run the docker-tls-configurator on the docker server you wish to install the TLS certs on.

It will configure the docker service by:
- generate a certificate and key and your own Certificate Authority (CA)
- generate server and client TLS certificates
- place the CA

## Requirements

- Docker CE installed
- Ubuntu 18.04.3 LTS bionic
- openssl

## Usage

```
./docker-tls-configurator.sh

A simple tool to configure TLS certificates for docker

Usage:
  docker-tls-configurator <hostname> <ip>

 hostname = DNS hostname of server running the docker daemon
 ip       = IP address of server running the docker daemon
```

## Connecting to the Server

### Via Portainer

### Via Command line
