#!/bin/bash

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

if ! grep "^vmonitor-agent:" /etc/group &>/dev/null; then
    groupadd -r vmonitor-agent
fi

if ! id vmonitor-agent &>/dev/null; then
    useradd -r -M vmonitor-agent -s /bin/false -d /etc/vmonitor-agent -g vmonitor-agent
fi

if [[ -d /etc/opt/vmonitor-agent ]]; then
    # Legacy configuration found
    if [[ ! -d /etc/vmonitor-agent ]]; then
        # New configuration does not exist, move legacy configuration to new location
        echo -e "Please note, vmonitor-agent's configuration is now located at '/etc/vmonitor-agent' (previously '/etc/opt/vmonitor-agent')."
        mv -vn /etc/opt/vmonitor-agent /etc/vmonitor-agent

        if [[ -f /etc/vmonitor-agent/vmonitor-agent.conf ]]; then
            backup_name="vmonitor-agent.conf.$(date +%s).backup"
            echo "A backup of your current configuration can be found at: /etc/vmonitor-agent/${backup_name}"
            cp -a "/etc/vmonitor-agent/vmonitor-agent.conf" "/etc/vmonitor-agent/${backup_name}"
        fi
    fi
fi

# if [! -d /etc/vmonitor-agent/ ]; then
#     mkdir /etc/vmonitor-agent/
# fi