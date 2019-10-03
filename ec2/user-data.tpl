#!/bin/bash

echo ECS_CLUSTER=${ecs-cluster-name} > /etc/ecs/ecs.config

## rexray ##
# open file descriptor for stderr
exec 2>>/var/log/ecs/ecs-agent-install.log
set -x

# install the Docker rexray volume plugins
docker plugin install rexray/ebs REXRAY_PREEMPT=true EBS_REGION=${ecs-region-name} --grant-all-permissions
docker plugin install rexray/efs --grant-all-permissions

#restart the ECS agent
docker restart ecs-agent
