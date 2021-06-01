#!/bin/bash

set -x
set -e

set -a
. $1
set +a

ls -la
rm -rf /opt/kube/cenit-ui
mkdir -p /opt/kube/cenit-ui

cp -a cenit-ui/. /opt/kube/cenit-ui/
ls -la /opt/kube/cenit-ui

docker run --rm \
-v /opt/kube:/root/.kube \
banst/awscli s3 cp /root/.kube/cenit-ui s3://$BUCKET_NAME --recursive