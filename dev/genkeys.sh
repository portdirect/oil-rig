#!/usr/bin/env bash

set -ex

BASEPATH=$(pwd)
CONTROL=$BASEPATH/pump/k8s-control/files/pki
WORKER=$BASEPATH/pump/k8s-worker/files

WORKDIR=$(mktemp -d)
pushd $WORKDIR

cat <<EOS > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
DNS.5 = k8s
DNS.6 = k8s.nb001-c001
DNS.7 = k8s.nb001-c001.svc
DNS.8 = k8s.nb001-c001.svc.cluster.local
EOS

cat <<EOS > openssl-kubelet.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = m0
DNS.2 = m1
DNS.3 = m2
IP.1 = 192.168.77.10
IP.2 = 192.168.77.11
IP.3 = 192.168.77.12
EOS

openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 10000 -out ca.crt -subj "/CN=kube-ca"

openssl genrsa -out service.key 2048
openssl req -new -key service.key -out service.csr -subj "/CN=kube-service" -config openssl.cnf
openssl x509 -req -in service.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out service.crt -days 365 -extensions v3_req -extfile openssl.cnf

openssl genrsa -out kubelet.key 2048
openssl req -new -key kubelet.key -out kubelet.csr -subj "/CN=kube-kubelet" -config openssl-kubelet.cnf
openssl x509 -req -in kubelet.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kubelet.crt -days 365 -extensions v3_req -extfile openssl-kubelet.cnf

openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr -subj "/CN=kube-admin/O=system:masters"
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365

openssl genrsa -out sa.key 2048
openssl rsa -in sa.key -pubout > sa.pub

cp ca.crt $CONTROL/certs/ca.crt
cp client.crt $CONTROL/certs/client.crt
cp service.crt $CONTROL/certs/apiserver.crt
cp service.crt $CONTROL/certs/controller-manager.crt
cp service.crt $CONTROL/certs/proxy.crt
cp service.crt $CONTROL/certs/scheduler.crt

cp ca.key $CONTROL/keys/priv/ca/ca.key
cp client.key $CONTROL/keys/priv/client/client.key
cp service.key $CONTROL/keys/priv/apiserver/apiserver.key
cp service.key $CONTROL/keys/priv/controller-manager/controller-manager.key
cp service.key $CONTROL/keys/priv/proxy/proxy.key
cp service.key $CONTROL/keys/priv/scheduler/scheduler.key

cp sa.pub $CONTROL/keys/pub/sa.pub
cp sa.key $CONTROL/keys/priv/sa/sa.key

cp ca.crt $WORKER/certs/ca.crt
cp client.crt $WORKER/certs/client.crt
cp kubelet.crt $WORKER/certs/kubelet.crt

cp client.key $WORKER/keys/client.key
cp kubelet.key $WORKER/kubelet.key

popd
