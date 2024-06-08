#!/bin/sh

PREVIOUS_IPV4=""
SERVICES="http://ipinfo.io/ip" # Add services into existing string, separated by space
index=0

# Function to get the list of domains
get_domains() {
    curl -s -X GET "https://api.dynu.com/v2/dns" \
    -H "accept: application/json" \
    -H "API-Key: ${DYNU_API_KEY}"
}

# Function to get DNS records
get_dns_records() {
    curl -s -X GET "https://api.dynu.com/v2/dns/${1}/record" \
    -H "accept: application/json" \
    -H "API-Key: ${API_KEY}"
}

while true; do
    for SERVICE in $SERVICES; do
        CURRENT_IPV4=$(curl -s "$SERVICE")
        # CURRENT_IPV6=$(wget -qO- "https://ip6.me/api/")
        if [ "$CURRENT_IPV4" != "$PREVIOUS_IPV4" ]; then
            echo "Updating IPV4 from $PREVIOUS_IPV4 to $CURRENT_IPV4"
            echo # Add a line break
            wget -qO- "http://api.dynu.com/nic/update?myip=${CURRENT_IPV4}&hostnme=${DYNU_HOSTNAME}&username=${DYNU_USERNAME}&password=${DYNU_PASSWORD}"
            PREVIOUS_IPV4=$CURRENT_IPV4
        fi
        sleep $POLLING_INTERVAL
        echo "CURRENT_IPV4: ${CURRENT_IPV4}"
        echo "DYNU_HOSTNAME: ${DYNU_HOSTNAME}"
        echo 
    done
done
