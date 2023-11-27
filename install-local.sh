#!/bin/sh

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

if [[ ! $V_USER || ! $V_PASS || ! $V_HOST || ! $V_PORT ]]; then
  printf "\033[31mV_USER, V_PASS, V_HOST, V_PORT not available in environment.\033[0m\n"
  exit 1;
fi

# Root user detection
if [[ $(echo "$UID") -ne 0 ]]; then
    sudo_cmd=''
    printf "\n\033[31mRun cmd as root.\033[0m\n"
    exit 1;
fi


# $sudo_cmd dpkg -i /home/annd2/Downloads/vmonitor-agent_nightly_amd64.deb
$sudo_cmd dpkg -i /home/annd2/Documents/vdb/trash/opentelemetry-collector-contrib-release/build/dist/vmonitor-agent_nightly_amd64.deb

# Set the configuration
printf "\033[34m\n* Adding ENV to the Agent configuration: /etc/default/vmonitor-agent\n\033[0m\n"

V_USER_TEMP="$V_USER"
V_PASS_TEMP="$V_PASS"
V_HOST_TEMP="$V_HOST"
V_PORT_TEMP="$V_PORT"

V_USER="V_USER=$V_USER"
V_PASS="V_PASS=$V_PASS"
V_HOST="V_HOST=$V_HOST"
V_PORT="V_PORT=$V_PORT"

list_env=( $V_USER $V_PASS $V_HOST $V_PORT)
printf "%s\n" "${list_env[@]}" | $sudo_cmd tee /etc/default/vmonitor-agent

# # restart agent
# printf "\033[34m* Starting the Agent...\n\033[0m\n"
$sudo_cmd service vmonitor-agent restart
