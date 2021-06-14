#!/bin/bash

set -x
set -e

# $1 -> path the env vars to load
# $2 -> build number

# From BAMBOO is passed, as an argument, the name of the .env file to load according to the branch and domain
set -a
. $1
set +a

docker run --rm amazon/aws-cli \
ecr get-login-password \
--region $AWS_REGION | docker login \
--username AWS --password-stdin \
$AWS_CONTAINER_REGISTRY

APP_VERSION=`cat version`
echo "Version: $APP_VERSION"

TAG=$GIT_BRANCH.$VELOSIMO_DOMAIN.$APP_VERSION.$2
TAGLATEST=$GIT_BRANCH.$VELOSIMO_DOMAIN.latest

echo "tag: $TAG"
echo "tag latest: $TAGLATEST"
echo "image: $CONTAINER_IMAGE_NAME"
echo "registry: $AWS_CONTAINER_REGISTRY"

docker tag velosimo/$CONTAINER_IMAGE_NAME:$GIT_BRANCH $AWS_CONTAINER_REGISTRY/$CONTAINER_IMAGE_NAME:$TAG

docker tag velosimo/$CONTAINER_IMAGE_NAME:$GIT_BRANCH $AWS_CONTAINER_REGISTRY/$CONTAINER_IMAGE_NAME:$TAGLATEST

docker push $AWS_CONTAINER_REGISTRY/$CONTAINER_IMAGE_NAME:$TAG
docker push $AWS_CONTAINER_REGISTRY/$CONTAINER_IMAGE_NAME:$TAGLATEST

docker images

