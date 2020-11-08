#!/usr/bin/env bash

# usage <url>
install_mms() {
  echo "Installing Ops Manager"

  curl -L $1 -o /tmp/mongodb-mms.rpm
  rpm -ivh /tmp/mongodb-mms.rpm
  rm /tmp/mongodb-mms.rpm
}

configure_mms() {
  echo "Configuring Ops Manager"
}

# -------------------------------------------------------------------------------------------------------------------------------------
#                                                    CLI
# -------------------------------------------------------------------------------------------------------------------------------------

cli_help() {
  cli_name=${0##*/}
  echo "
Ops Manager bootstrap CLI
Usage: $cli_name [command]
Commands:
  install     Install
  null        Do nothing
  *           Help
"
  exit 1
}

case "$1" in
  install)
    shift
    install_mms $@
    ;;
  configure)
    configure_mms
    ;;
  null)
    exit 0
    ;;
  *)
    cli_help
    ;;
esac