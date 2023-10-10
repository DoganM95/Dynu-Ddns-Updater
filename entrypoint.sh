#!/bin/sh

PREVIOUS_IPV4=""

while true; do
    CURRENT_IPV4=$(curl -s "https://ipinfo.io/ip")
    if [ "$CURRENT_IPV4" != "$PREVIOUS_IPV4" ]; then
        echo "New IPV4: $CURRENT_IPV4"
        echo # Add a line break
        curl -s "https://api.dynu.com/nice/update?username=${DYNU_USERNAME}&password=${DYNU_PASSWORD}&hostname=${DYNU_HOSTNAME}&myip=${CURRENT_IPV4}"
        PREVIOUS_IPV4=$CURRENT_IPV4
    fi
    sleep $POLLING_INTERVAL
done