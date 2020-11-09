#!/usr/bin/env bash

#usage: <sslKeyFile> <mmsGroupId> <mmsApiKey>
install_agents() {
  if [ "$#" -ne 3 ]; then
    agents_help
  fi

  local mmsGroupId=$2
  local mmsApiKey=$3
  local agentRpmFilename=`terraform output -json agent_rpm | jq -r '.'`
  local nodes=`terraform output -json node_public_ip | jq -r '.[]'`
  local mmsBaseUrl=`terraform output -json mms_url | jq -r '.'`

  for HOST in $nodes
  do
    echo "insalling agent on $HOST"

    ssh -i $1 -o StrictHostKeyChecking=no ec2-user@$HOST <<- EOF
      curl -OL $mmsBaseUrl/download/agent/automation/$agentRpmFilename
      sudo rpm -U $agentRpmFilename
      sudo sed -ir "s|^mmsBaseUrl=.*|mmsBaseUrl=$mmsBaseUrl|" /etc/mongodb-mms/automation-agent.config
      sudo sed -ir "s|^mmsApiKey=.*|mmsApiKey=$mmsApiKey|" /etc/mongodb-mms/automation-agent.config
      sudo sed -ir "s|^mmsGroupId=.*|mmsGroupId=$mmsGroupId|" /etc/mongodb-mms/automation-agent.config
      sudo chown mongod:mongod /data
      sudo chown mongod:mongod -R /etc/mongodb
      sudo systemctl restart mongodb-mms-automation-agent.service
EOF
  done
}


# -------------------------------------------------------------------------------------------------------------------------------------
#                                                    CLI
# -------------------------------------------------------------------------------------------------------------------------------------

agents_help() {
  cli_name=${0##*/}
  echo "
MongoDB bootstrap CLI
Usage: $cli_name agents <sslKeyFile> <mmsGroupId> <mmsApiKey>
"
  exit 1
}

cli_help() {
  cli_name=${0##*/}
  echo "
MongoDB bootstrap CLI
Usage: $cli_name [command]
Commands:
  agents     Install Ops Manager agents on nodes
  null       Do nothing
  *          Help
"
  exit 1
}

case "$1" in
  agents)
    shift
    install_agents $@
    ;;
  null)
    exit 0
    ;;
  *)
    cli_help
    ;;
esac