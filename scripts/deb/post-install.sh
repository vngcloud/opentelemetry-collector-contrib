#!/bin/bash

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

LOG_DIR=/var/log/vmonitor-agent
SCRIPT_DIR=/usr/lib/vmonitor-agent/scripts

function install_init {
    cp -f $SCRIPT_DIR/init.sh /etc/init.d/vmonitor-agent
    chmod +x /etc/init.d/vmonitor-agent
}

function install_systemd {
    #shellcheck disable=SC2086
    cp -f $SCRIPT_DIR/vmonitor-agent.service $1
    systemctl enable vmonitor-agent || true
    systemctl daemon-reload || true
}

function install_update_rcd {
    update-rc.d vmonitor-agent defaults
}

function install_chkconfig {
    chkconfig --add vmonitor-agent
}

# Remove legacy symlink, if it exists
if [[ -L /etc/init.d/vmonitor-agent ]]; then
    rm -f /etc/init.d/vmonitor-agent
fi
# Remove legacy symlink, if it exists
if [[ -L /etc/systemd/system/vmonitor-agent.service ]]; then
    rm -f /etc/systemd/system/vmonitor-agent.service
fi

# Add defaults file, if it doesn't exist
if [[ ! -f /etc/default/vmonitor-agent ]]; then
    touch /etc/default/vmonitor-agent
fi

# Add .d configuration directory
if [[ ! -d /etc/vmonitor-agent/vmonitor-agent.d ]]; then
    mkdir -p /etc/vmonitor-agent/vmonitor-agent.d
fi

# If 'vmonitor-agent.conf' is not present use package's sample (fresh install)
if [[ ! -f /etc/vmonitor-agent/vmonitor-agent.conf ]] && [[ -f /etc/vmonitor-agent/vmonitor-agent.conf.sample ]]; then
   cp /etc/vmonitor-agent/vmonitor-agent.conf.sample /etc/vmonitor-agent/vmonitor-agent.conf
fi

test -d $LOG_DIR || mkdir -p $LOG_DIR
chown -R -L vmonitor-agent:vmonitor-agent $LOG_DIR
chmod 755 $LOG_DIR

if [ -d /run/systemd/system ]; then
    install_systemd /lib/systemd/system/vmonitor-agent.service
    # if and only if the service was already running then restart
    deb-systemd-invoke try-restart vmonitor-agent.service >/dev/null || true
else
	# Assuming SysVinit
	install_init
	# Run update-rc.d or fallback to chkconfig if not available
	if which update-rc.d &>/dev/null; then
		install_update_rcd
	else
		install_chkconfig
	fi
	invoke-rc.d vmonitor-agent restart
fi
