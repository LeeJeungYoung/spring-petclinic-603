#!/bin/bash

echo "Remove exited container"
cd /home/ubuntu/script
docker compose down || true
