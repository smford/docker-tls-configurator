# docker-tls-configurator

A simple script that generates and configures TLS for docker, allowing you quickly and easily get it working.

Based upon this document: [Protect the Docker daemon socket](https://docs.docker.com/engine/security/https/)

Configures the right things to allow easy connection from the command line or [Portainer.io](https://www.portainer.io/)

## Tested on

- OS
  - Ubuntu 18.04.3 LTS bionic
- Docker
  - 19.03.5
  - 19.03.6

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

1. Settings
   | Setting | Default |
   |:--|:--|
   | Name | [hostname] |
   | Endpoint URL | [hostname]:2376 or [ip]:2376 |
   | Select | TLS with server and client verification |
   | TLS CA certificate | [hostname]-ca.pem |
   | TLS certificate | [hostname]-client-cert.pem |
   | TLS key | [hostname]-client-key.pem |

### Via Command line

1. Enable TLS connection via default:
   ```
   export HOST="[hostname]"
   mkdir ~/.docker
   cp $HOST/$HOST-ca.pem ~/.docker/ca.pem
   cp $HOST/$HOST-client-cert.pem ~/.docker/client.pem
   cp $HOST/$HOST-client-key.pem ~/.docker/key.pem
   export DOCKER_HOST=tcp://$HOST:2376 DOCKER_TLS_VERIFY=1
   docker info
	 ```
1. Single connection
   ```
   export HOST="[hostname]"
   docker --tlsverify --tlscacert=$HOST-ca.pem --tlscert=$HOST-client-cert.pem --tlskey=$HOST-client-key.pem -H=$HOST:2376 version
   ```
1. Multiple docker servers
   ```
   export DHOST="[hostname]"
   export DOCKER_CERT_PATH=~/.docker/$DHOST/
   export DOCKER_HOST=tcp://$DHOST:2376 DOCKER_TLS_VERIFY=1
   ```
	 - have the each servers certificates saved in to ~/.docker/[hostname] directories with ca.pem, client.pem and key.pem
	 - and to change which server to connect to do `export DHOST="g1"` or `export DHOST="g2"`
