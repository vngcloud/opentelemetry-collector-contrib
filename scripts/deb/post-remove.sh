#!/bin/bash

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

function disable_systemd {
    systemctl disable vmonitor-agent
    rm -f $1
}

function disable_update_rcd {
    update-rc.d -f vmonitor-agent remove
    rm -f /etc/init.d/vmonitor-agent
}

function disable_chkconfig {
    chkconfig --del vmonitor-agent
    rm -f /etc/init.d/vmonitor-agent
}

if [ "$1" == "remove" -o "$1" == "purge" ]; then
	# Remove/purge
	rm -f /etc/default/vmonitor-agent

	if [[ "$(readlink /proc/1/exe)" == */systemd ]]; then
		disable_systemd /lib/systemd/system/vmonitor-agent.service
	else
		# Assuming sysv
		# Run update-rc.d or fallback to chkconfig if not available
		if which update-rc.d &>/dev/null; then
			disable_update_rcd
		else
			disable_chkconfig
		fi
	fi
fi
