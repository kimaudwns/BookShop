#!/bin/bash
docker-compose -f /home/ubuntu/deploy/scripts/docker-compose.yml down || true
docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "kimaudwns/bookshop" | grep -v "${current_image}" | grep -v "${build_image}" | awk '{print $2}' | xargs -r docker rmi || true
