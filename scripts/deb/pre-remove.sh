#!/bin/bash

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

if [ -d /run/systemd/system ]; then
	if [ "$1" = remove ]; then
		deb-systemd-invoke stop vmonitor-agent.service
	fi
else
	# Assuming sysv
	invoke-rc.d vmonitor-agent stop
fi
