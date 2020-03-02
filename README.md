# docker-tls-configurator

A simple script that generates and configures TLS for docker, allowing you quickly and easily get it working.

Based upon this document: [Protect the Docker daemon socket](https://docs.docker.com/engine/security/https/)

Configures the right things to allow easy connection from [Portainer.io](https://www.portainer.io/)

## Tested on

 - Ubuntu 18.04.3 LTS bionic

## Instructions

Run the docker-tls-configurator.sh on the docker server you wish to install the TLS certs on.

It will configure the docker service by:
1. Generate CA Key
1. Generate CA Certificate
1. Generate Server Key
1. Generate Server CSR
1. Configure Server CSR
1. Generate Signed Certificate
1. Generate Client Key
1. Generate Client CSR
1. Configure Client Certificate
1. Generate Client Signed Certificate
1. Configure Docker: Certificates
1. Configure Docker: Keys
1. Configure Docker Service: /etc/docker/daemon.json
1. Configure Docker Service: /etc/systemd/system/docker.service.d/override.conf

The certificates, keys, CSRs, certificate configuration files are then saved in to a directory names after the server hostname in the current directory.

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

| Setting | Default |
|:--|:--|
| Name | [hostname] |
| Endpoint URL | [hostname]:2376 or [ip]:2376 |
| Select | TLS with server and client verification |
| TLS CA certificate | [hostname]-ca.pem |
| TLS certificate | [hostname]-client-cert.pem |
| TLS key | [hostname]-client-key.pem |

### Via Command line
