#!/bin/bash
set -e

# Get folder name as image name
IMAGE_NAME="$(basename "$PWD")"
ARCHIVE="${IMAGE_NAME}.tar.gz"
SSH_NAME="xus"

REMOTE_PATH="/opt/stack"

echo "1. Building image..."
docker build -t ${IMAGE_NAME}:latest .

echo "2. Creating archive..."
docker save ${IMAGE_NAME}:latest | gzip >$ARCHIVE

echo "3. Uploading to server..."
scp $ARCHIVE ${SSH_NAME}:${REMOTE_PATH}/

echo "4. Loading image + cleaning on server..."
ssh ${SSH_NAME} "cd ${REMOTE_PATH} && gunzip -c ${ARCHIVE} | docker load && rm -f ${ARCHIVE}"

echo "5. Restarting stack..."
ssh ${SSH_NAME} "cd ${REMOTE_PATH} && docker compose up -d"

echo "6. Cleaning local archive..."
rm -f $ARCHIVE

echo "Done"
