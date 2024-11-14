#!/bin/bash

# 현재 실행 중인 Docker 컨테이너 종료
echo "Stopping and removing existing container..."
docker stop bookshop || true
docker rm bookshop || true

# 현재 실행 중인 이미지 삭제
echo "Removing old Docker image..."
docker rmi kimaudwns/bookshop:latest || true

# 이미지가 없을 경우 메시지 출력
if [[ $? -eq 0 ]]; then
    echo "Docker image kimaudwns/bookshop:latest removed successfully."
else
    echo "No image found or failed to remove the image."
fi

# 새로운 이미지 빌드 및 실행
echo "Starting new deployment..."
docker-compose -f /home/ubuntu/deploy/scripts/docker-compose.yml up -d --build
