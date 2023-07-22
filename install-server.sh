#!/bin/bash

export X_UID=$(id -u)
export X_GID=$(id -g)

echo "UID=$X_UID, GID=$X_GID"

docker-compose up -d

echo "部署完成"