#!/usr/bin/env bash

#usage: <sslKeyFile> <mmsBaseUrl> <mmsGroupId> <mmsApiKey>
configure_agents() {
  if [ "$#" -ne 4 ]; then
    configure_agents_help
  fi

  local nodes=`terraform output -json node_public_ip | jq -r '.[]'`
  for HOST in $nodes
  do
    echo "configuring agent on $HOST"
    ssh -i $1 -o StrictHostKeyChecking=no ec2-user@$HOST <<- EOF
      sudo sed -ir "s|^mmsBaseUrl=.*|mmsBaseUrl=$2|" /etc/mongodb-mms/automation-agent.config
      sudo sed -ir "s|^mmsGroupId=.*|mmsGroupId=$3|" /etc/mongodb-mms/automation-agent.config
      sudo sed -ir "s|^mmsApiKey=.*|mmsApiKey=$4|" /etc/mongodb-mms/automation-agent.config
      sudo systemctl restart mongodb-mms-automation-agent.service
EOF
  done
}

# -------------------------------------------------------------------------------------------------------------------------------------
#                                                    CLI
# -------------------------------------------------------------------------------------------------------------------------------------


configure_agents_help() {
  cli_name=${0##*/}
  echo "
MongoDB bootstrap CLI
Usage: $cli_name configure_agents <sslKeyFile> <mmsBaseUrl> <mmsGroupId> <mmsApiKey>
"
  exit 1
}

cli_help() {
  cli_name=${0##*/}
  echo "
MongoDB bootstrap CLI
Usage: $cli_name [command]
Commands:
  wait        Wait
  initiate    Initiate replica set
  add_shard   Add shard to cluster
  null        Do nothing
  *           Help
"
  exit 1
}

case "$1" in
  configure_agents)
    shift
    configure_agents $@
    ;;
  initiate)
    shift
    initiate_replica_set $@
    ;;
  add_shard)
    shift
    add_shard $@
    ;;
  null)
    exit 0
    ;;
  *)
    cli_help
    ;;
esac