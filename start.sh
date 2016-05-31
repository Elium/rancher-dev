#!/bin/bash

echo "Start the stack"
docker-compose up -d --build --force-recreate

echo "We are waiting rancherdev_rancher-agent-local_1 to get a fully up service"
docker wait rancherdev_rancher-agent-local_1 >> /dev/null

IP=$(docker-machine ip default || 'localhost')
echo "Enjoy your rancher server: http://$IP:18080"