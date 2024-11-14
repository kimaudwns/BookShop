#!/bin/bash

# 현재 실행 중인 Docker 컨테이너 종료
echo "Stopping and removing existing container..."
docker stop bookshop || true
docker rm bookshop || true

# 현재 실행 중인 이미지 삭제
echo "Removing old Docker image..."
if docker images | grep -q "kimaudwns/bookshop:latest"; then
    docker rmi kimaudwns/bookshop:latest || true
    echo "Docker image kimaudwns/bookshop:latest removed successfully."
else
    echo "No old image found to remove."
fi

# 새로운 이미지 빌드 및 실행
echo "Starting new deployment..."
docker-compose -f /home/ubuntu/deploy/scripts/docker-compose.yml up -d --build
