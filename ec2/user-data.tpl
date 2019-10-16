#!/bin/bash

echo ECS_CLUSTER=${ecs-cluster-name} > /etc/ecs/ecs.config

##
echo vm.max_map_count=262144 >> /etc/sysctl.conf
echo fs.file-max=100000 >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144
sysctl -w fs.file-max=100000
sysctl vm.max_map_count
sysctl fs.file-max
sed -i -e 's/1024:4096/65536:65536/g' /etc/sysconfig/docker
systemctl restart docker

## rexray ##

# install the Docker rexray volume plugins
docker plugin install rexray/ebs REXRAY_PREEMPT=true EBS_REGION=${ecs-region-name} --grant-all-permissions
docker plugin install rexray/efs REXRAY_PREEMPT=true --grant-all-permissions

