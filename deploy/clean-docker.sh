#!/bin/bash

set -x
set -e

echo "cleaning docker volumes and images.."

docker image prune -af
docker volume prune -f