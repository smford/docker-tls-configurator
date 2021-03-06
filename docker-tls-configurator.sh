#!/usr/bin/env bash

set -euo pipefail

VERSION="v1"

# Tested on:
# - Ubuntu 18.04.3 LTS bionic

if [[ $# < 2 ]]; then
  echo ""
  echo "A simple tool to configure TLS certificates for docker"
  echo ""
  echo -e "Usage:\n  docker-tls-configurator.sh <hostname> <ip>"
  echo ""
  echo " hostname = DNS hostname of server running the docker daemon"
  echo " ip       = IP address of server running the docker daemon"
  echo ""
  exit 1
fi

HOST="${1}"
IP="${2}"

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

HOSTDIR=${SCRIPTDIR}/${HOST}

echo -e "Host=${HOST}"
echo -e "IP=${IP}"
echo -e "SCRIPTDIR=${SCRIPTDIR}"
echo -e "HOSTDIR=${HOSTDIR}"

read -s -p "Certificate Authority Password: " CAPASSWORD1
echo ""
read -s -p "               Verify Password: " CAPASSWORD2

if [ "${CAPASSWORD1}" != "${CAPASSWORD2}" ]; then
  echo "Passwords do not match, exiting"
  exit 1
else
  echo "Passwords match"
fi


# temporarily used to bypass generation of certs
#if false; then

if [[ ! -d ${HOSTDIR} ]]; then
  mkdir ${HOSTDIR}
fi

echo "1: Generate CA Key"
openssl genrsa -aes256 -passout pass:${CAPASSWORD1} -out ${HOSTDIR}/${HOST}-ca-key.pem 4096
echo "===================================================="

echo "2: Generate CA Certificate"
openssl req -new -passin pass:${CAPASSWORD1} -x509 -days 365 -key ${HOSTDIR}/${HOST}-ca-key.pem -sha256 -out ${HOSTDIR}/${HOST}-ca.pem
echo "===================================================="

echo "3: Generate Server Key"
openssl genrsa --passout pass:${CAPASSWORD1} -out ${HOSTDIR}/${HOST}-server-key.pem 4096
echo "===================================================="

echo "4: Generate Server CSR"
openssl req -subj "/CN=$HOST" -sha256 -new -key ${HOSTDIR}/${HOST}-server-key.pem -out ${HOSTDIR}/${HOST}-server.csr
echo "===================================================="

echo "5: Configure Server CSR"
echo subjectAltName = DNS:${HOST},IP:${IP},IP:127.0.0.1 >> ${HOSTDIR}/${HOST}-extfile.cnf
echo extendedKeyUsage = serverAuth >> ${HOSTDIR}/${HOST}-extfile.cnf
echo "===================================================="

echo "6: Generate Signed Certificate"
openssl x509 -passin pass:${CAPASSWORD1} -req -days 365 -sha256 -in ${HOSTDIR}/${HOST}-server.csr -CA ${HOSTDIR}/${HOST}-ca.pem -CAkey ${HOSTDIR}/${HOST}-ca-key.pem -CAcreateserial -out ${HOSTDIR}/${HOST}-server-cert.pem -extfile ${HOSTDIR}/${HOST}-extfile.cnf
echo "===================================================="

echo "7: Generate Client Key"
openssl genrsa -out ${HOSTDIR}/${HOST}-client-key.pem 4096
echo "===================================================="

echo "8: Generate Client CSR"
openssl req -subj '/CN=client' -new -key ${HOSTDIR}/${HOST}-client-key.pem -out ${HOSTDIR}/${HOST}-client.csr
echo "===================================================="

echo "9: Configure Client Certificate"
echo extendedKeyUsage = clientAuth > ${HOSTDIR}/${HOST}-client-extfile.cnf
echo "===================================================="

echo "10: Generate Client Signed Certificate"
openssl x509 -passin pass:${CAPASSWORD1} -req -days 365 -sha256 -in ${HOSTDIR}/${HOST}-client.csr -CA ${HOSTDIR}/${HOST}-ca.pem -CAkey ${HOSTDIR}/${HOST}-ca-key.pem -CAcreateserial -out ${HOSTDIR}/${HOST}-client-cert.pem -extfile ${HOSTDIR}/${HOST}-client-extfile.cnf
echo "===================================================="

exit
# fi

echo "11: Configure Docker: Certificates"
cp ${HOSTDIR}/${HOST}-ca.pem /etc/docker
cp ${HOSTDIR}/${HOST}-server-cert.pem /etc/docker
chmod -v 0444 /etc/docker/${HOST}-ca.pem
chmod -v 0444 /etc/docker/${HOST}-server-cert.pem
echo "===================================================="

echo "12: Configure Docker: Keys"
cp ${HOSTDIR}/${HOST}-server-key.pem /etc/docker
chmod -v 0400 /etc/docker/${HOST}-server-key.pem
echo "===================================================="

echo "13: Configure service: /etc/docker/daemon.json"
cat >/etc/docker/daemon.json <<EOL
{
	"tls": true,
	"tlsverify": true,
	"tlscacert": "/etc/docker/${HOST}-ca.pem",
	"tlscert": "/etc/docker/${HOST}-server-cert.pem",
	"tlskey": "/etc/docker/${HOST}-server-key.pem"
}
EOL
chmod -v 0644 /etc/docker/daemon.json
echo "===================================================="

echo "14: Configure service: /etc/systemd/system/docker.service.d/override.conf"
if [[ ! -d /etc/systemd/system/docker.service.d ]]; then
  mkdir /etc/systemd/system/docker.service.d
  chown root:root /etc/systemd/system/docker.service.d
  chmod 0755 /etc/systemd/system/docker.service.d
fi
cat >/etc/systemd/system/docker.service.d/override.conf <<EOL
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2376 -H tcp://${IP}:2376
EOL
chmod -v 0644 /etc/systemd/system/docker.service.d/override.conf
systemctl daemon-reload
echo "===================================================="

echo "Completed Installation."
echo -e "- created certificate authority key and certificate, ${HOST}-ca-key.pem, ${HOST}-ca.pem"
echo -e "- created docker server key and certificate, ${HOST}-server-key.pem, ${HOST}-server-cert.pem"
echo -e "- created client key and certificate, and signed with server certificate, ${HOST}-client-key.pem, ${HOST}-client-key.pem"
echo -e "- installed certificate authority certificate, server key and key in to /etc/docker"
echo -e "- configured docker server TLS, using the server certificate and key"
echo -e "- configured docker server to expose 2736 for TLS connections"
echo ""
echo -e "Portainer Configuration:"
echo -e "Name:               ${HOST}"
echo -e "Endpoint URL:       ${IP}:2376"
echo -e "Select:             TLS with server and client verification"
echo -e "TLS CA certificate: ${HOST}-ca.pem"
echo -e "TLS certificate:    ${HOST}-client-cert.pem"
echo -e "TLS key:            ${HOST}-client-key.pem"
