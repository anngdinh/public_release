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

BASE_URL="https://github.com/anngdinh/public_release/releases/download"
VERSION=v1.0.0
PACKAGE_NAME="vmonitor-agent_nightly_amd64.deb"
URI="$BASE_URL/${VERSION}/${PACKAGE_NAME}"
echo $URI
if command -v curl 2>/dev/null; then
    curl -L $URI -o /tmp/$PACKAGE_NAME
else
    rm -rf $PACKAGE_NAME
    wget $URI
    cp --remove-destination $PACKAGE_NAME /tmp/$PACKAGE_NAME
fi
printf "\033[34m\n* Installing the vMonitor Agent package\n\033[0m\n"

$sudo_cmd dpkg -i /tmp/$PACKAGE_NAME

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
