#!/bin/sh

PREVIOUS_IPV4=""
SERVICES="http://ipinfo.io/ip" # Add services into existing string, separated by space
index=0

while true; do
    for SERVICE in $SERVICES; do
        CURRENT_IPV4=$(curl -s "$SERVICE")
        # CURRENT_IPV6=$(wget -qO- "https://ip6.me/api/")
        if [ "$CURRENT_IPV4" != "$PREVIOUS_IPV4" ]; then
            echo "New IPV4: $CURRENT_IPV4"
            echo # Add a line break
            wget -qO- "http://api.dynu.com/nic/update?myip=${CURRENT_IPV4}&hostnme=${DYNU_HOSTNAME}&username=${DYNU_USERNAME}&password=${DYNU_PASSWORD}"
            PREVIOUS_IPV4=$CURRENT_IPV4
        fi
        sleep $POLLING_INTERVAL
    done
done
