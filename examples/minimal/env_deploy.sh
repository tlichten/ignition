#!/usr/bin/env bash

. parse_yaml.sh

eval $(parse_yaml env.yaml)
eval $(parse_yaml ./examples/$env_example/env.yaml)

if [ "$env_autodeploy" = true ]; then
  fuel env create --name lab --rel 2 --net-segment-type vlan
  fuel node set --node 00:00 --role controller --env 1
  fuel node set --node 00:01 --role compute --env 1
  fuel node set --node 00:02 --role compute --env 1

  echo 'Starting deploy ...'
  fuel deploy-changes --env 1
  echo "Environment ready."
  echo "Horizon available at http://instance-public-ip."
fi


