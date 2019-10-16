#!/bin/bash

COMPOSE_PROJECT_NAME=elk ecs-cli compose service $1 --aws-profile mn-d01-cd --cluster tf-ecs-cluster
