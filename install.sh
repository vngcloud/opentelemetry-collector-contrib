#!/bin/sh

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

DEFAULT_VERSION=v1.0.0
DEFAULT_VMONITOR_SITE="https://monitoring-agent.vngcloud.vn:443"
DEFAULT_IAM_URL="https://iamapis.vngcloud.vn/accounts-api/v2/auth/token"
BASE_URL="https://github.com/vngcloud/opentelemetry-collector-contrib/releases/download"

if [ ! $VERSION ]; then
  printf "\033[31mVERSION environment variable not available.\033[0m\n"
  printf "\033[31mDefault VERSION is $DEFAULT_VERSION.\033[0m\n"
  VERSION=$DEFAULT_VERSION
fi

if [ ! $IAM_CLIENT_ID ]; then
  printf "\033[31mIAM_CLIENT_ID not available in IAM_CLIENT_ID environment variable.\033[0m\n"
  exit 1;
fi

if [ ! $IAM_CLIENT_SECRET ]; then
  printf "\033[31mIAM_CLIENT_SECRET not available in IAM_CLIENT_SECRET environment variable.\033[0m\n"
  exit 1;
fi

if [ ! $IAM_URL ]; then
  printf "\033[31mIAM_URL not available in IAM_URL environment variable.\033[0m\n"
  printf "\033[31mDefault IAM_URL is $DEFAULT_IAM_URL.\033[0m\n"
  IAM_URL=$DEFAULT_IAM_URL
fi

if [ ! $VMONITOR_SITE ]; then
  printf "\033[31mVMONITOR_SITE not available in VMONITOR_SITE environment variable.\033[0m\n"
  printf "\033[31mDefault site is $DEFAULT_VMONITOR_SITE.\033[0m\n"
  VMONITOR_SITE=$DEFAULT_VMONITOR_SITE
fi

if [[ ! $V_USER || ! $V_PASS || ! $V_HOST || ! $V_PORT ]]; then
  printf "\033[31mV_USER, V_PASS, V_HOST, V_PORT not available in environment.\033[0m\n"
  exit 1;
fi

KNOWN_DISTRIBUTION="(Debian|Ubuntu|RedHat|CentOS|openSUSE|Amazon|Arista|SUSE)"
DISTRIBUTION=$(lsb_release -d 2>/dev/null | grep -Eo $KNOWN_DISTRIBUTION  || grep -Eo $KNOWN_DISTRIBUTION /etc/issue 2>/dev/null || grep -Eo $KNOWN_DISTRIBUTION /etc/Eos-release 2>/dev/null || grep -m1 -Eo $KNOWN_DISTRIBUTION /etc/os-release 2>/dev/null || uname -s)

if [ $DISTRIBUTION = "Darwin" ]; then
  printf "\033[31mThis script does not support installing on the Mac."
  exit 1;
elif [ -f /etc/debian_version -o "$DISTRIBUTION" == "Debian" -o "$DISTRIBUTION" == "Ubuntu" ]; then
    OS="Debian"
elif [ -f /etc/redhat-release -o "$DISTRIBUTION" == "RedHat" -o "$DISTRIBUTION" == "CentOS" -o "$DISTRIBUTION" == "Amazon" ]; then
    OS="RedHat"
# Some newer distros like Amazon may not have a redhat-release file
elif [ -f /etc/system-release -o "$DISTRIBUTION" == "Amazon" ]; then
    OS="RedHat"
# Arista is based off of Fedora14/18 but do not have /etc/redhat-release
elif [ -f /etc/Eos-release -o "$DISTRIBUTION" == "Arista" ]; then
    OS="RedHat"
# openSUSE and SUSE use /etc/SuSE-release
elif [ -f /etc/SuSE-release -o "$DISTRIBUTION" == "SUSE" -o "$DISTRIBUTION" == "openSUSE" ]; then
    OS="SUSE"
fi

# Root user detection
if [[ $(echo "$UID") -ne 0 ]]; then
    sudo_cmd=''
    printf "\n\033[31mRun cmd as root.\033[0m\n"
    exit 1;
fi

# Install the necessary package sources
if [ $OS = "RedHat" ]; then
    echo -e "\033[34m\n* Installing RPM sources for vMonitor\n\033[0m"

    UNAME_M=$(uname -m)
    if [ "$UNAME_M"  == "i686" -o "$UNAME_M"  == "i386" -o "$UNAME_M"  == "x86" ]; then
        ARCHI="i386"
    else
        ARCHI="x86_64"
    fi

    printf "\033[34m* Installing the vMonitor Agent package\n\033[0m\n"

    PACKAGE_NAME="vmonitor-agent-nightly.${ARCHI}.rpm"
    URI="$BASE_URL/${VERSION}/${PACKAGE_NAME}"
    echo $URI
    if command -v curl 2>/dev/null; then
        curl -L $URI -o /tmp/$PACKAGE_NAME
    else
        rm -rf $PACKAGE_NAME
        wget $URI
        cp --remove-destination $PACKAGE_NAME /tmp/$PACKAGE_NAME
    fi

    $sudo_cmd rpm -i /tmp/$PACKAGE_NAME

elif [ $OS = "Debian" ]; then
    printf "\033[34m\n* Installing the vMonitor Agent package\n\033[0m\n"
    ARCHI=$(dpkg --print-architecture)
  
    PACKAGE_NAME="vmonitor-agent_nightly_${ARCHI}.deb"
    URI="$BASE_URL/${VERSION}/${PACKAGE_NAME}"
    echo $URI
    if command -v curl 2>/dev/null; then
        curl -L $URI -o /tmp/$PACKAGE_NAME
    else
        rm -rf $PACKAGE_NAME
        wget $URI
        cp --remove-destination $PACKAGE_NAME /tmp/$PACKAGE_NAME
    fi
    # curl -L "$BASE_URL/${VERSION}/${PACKAGE_NAME}" -o /tmp/$PACKAGE_NAME
    $sudo_cmd dpkg -i /tmp/$PACKAGE_NAME
    ERROR_MESSAGE=""

else
    printf "\033[31mYour OS or distribution are not supported by this install script.
Please follow the instructions on the Agent setup page:
    https://app.vngcloud.vn/account/settings#agent\033[0m\n"
    exit;
fi

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

IAM_CLIENT_ID_TEMP="$IAM_CLIENT_ID"
IAM_CLIENT_SECRET_TEMP="$IAM_CLIENT_SECRET"
IAM_URL_TEMP="$IAM_URL"
VMONITOR_SITE_TEMP="$VMONITOR_SITE"

IAM_CLIENT_ID="IAM_CLIENT_ID=$IAM_CLIENT_ID"
IAM_CLIENT_SECRET="IAM_CLIENT_SECRET=$IAM_CLIENT_SECRET"
IAM_URL="IAM_URL=$IAM_URL"
VMONITOR_SITE="VMONITOR_SITE=$VMONITOR_SITE"

list_env=( $V_USER $V_PASS $V_HOST $V_PORT $IAM_CLIENT_ID $IAM_CLIENT_SECRET $IAM_URL $VMONITOR_SITE)
printf "%s\n" "${list_env[@]}" | $sudo_cmd tee /etc/default/vmonitor-agent

# restart agent
printf "\033[34m* Starting the Agent...\n\033[0m\n"
$sudo_cmd service vmonitor-agent restart

# Wait for metrics
printf "\033[32m
Your Agent has started up for the first time.
at:
    https://vmonitor.vngcloud.vn/infrastructure\033[0m
Waiting for metrics..."

export V_USER=$V_USER_TEMP
export V_PASS=$V_PASS_TEMP
export V_HOST=$V_HOST_TEMP
export V_PORT=$V_PORT_TEMP

export IAM_CLIENT_ID=$IAM_CLIENT_ID_TEMP
export IAM_CLIENT_SECRET=$IAM_CLIENT_SECRET_TEMP
export IAM_URL=$IAM_URL_TEMP
export VMONITOR_SITE=$VMONITOR_SITE_TEMP

# Metrics are submitted, echo some instructions and exit
printf "\033[32m
Your Agent is running and functioning properly. It will continue to run in the
background and submit metrics to vMonitor.
If you ever want to stop the Agent, run:
    sudo service vmonitor-agent stop
And to run it again run:
    sudo service vmonitor-agent start
config:
    /etc/vmonitor-agent/vmonitor-agent.conf
    /etc/default/vmonitor-agent
\033[0m"
