#!/usr/bin/env bash
# Usage: ./deploy.sh <image> <user>@<host> <ssh-key-path>
IMAGE=$1
TARGET=$2
KEY=$3

ssh -o StrictHostKeyChecking=no -i "$KEY" "$TARGET" <<EOF
  docker pull $IMAGE
  docker rm -f juiceshop || true
  docker run -d --name juiceshop -p 3000:3000 --restart unless-stopped $IMAGE
EOF
