#!/bin/bash

set -e

docker_image="homkar8/aws-cicd-python-app:latest"

#stop old container if running
docker stop myapp || true
docker rm myapp || true

echo "Pulling latest docker image"
docker pull $docker_image

echo "Starting new container"
docker run -d --name myapp -p 5000:5000 $docker_image

echo "Deployment completed"