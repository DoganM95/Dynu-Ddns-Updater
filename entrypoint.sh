#!/bin/sh

SERVICES="http://ipinfo.io/ip" # Add services into existing string, separated by space

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
        -H "API-Key: ${DYNU_API_KEY}"
}

# Function to update DNS record
update_dns_record() {
    DOMAIN_ID=$1
    DNS_RECORD_ID=$2
    NEW_IPV4=$3

    curl -s -X POST "https://api.dynu.com/v2/dns/${DOMAIN_ID}/record/${DNS_RECORD_ID}" \
        -H "accept: application/json" \
        -H "API-Key: ${DYNU_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
        "nodeName": "'"$(echo $DYNU_DOMAIN_NAME | cut -d. -f1)"'",
        "recordType": "A",
        "address": "'"${NEW_IPV4}"'"
    }'
}

while true; do
    for SERVICE in $SERVICES; do
        CURRENT_IPV4=$(curl -s "$SERVICE")
        if [ "$CURRENT_IPV4" != "$PREVIOUS_IPV4" ]; then
            echo "Updating IPV4 from $PREVIOUS_IPV4 to $CURRENT_IPV4"
            echo # \n

            # Get the list of domains & extract the domain ID
            DOMAINS=$(get_domains)
            DOMAIN_ID=$(echo $DOMAINS | jq -r --arg name "$DYNU_DOMAIN_NAME" '.[] | select(.name == $name) | .id')

            if [ -z "$DOMAIN_ID" ]; then
                echo "Error: Domain ID for $DYNU_DOMAIN_NAME not found."
                exit 1
            fi

            # Get DNS records & extract record ID for given domain name
            DNS_RECORDS=$(get_dns_records $DOMAIN_ID)
            DNS_RECORD_ID=$(echo $DNS_RECORDS | jq -r --arg name "$DYNU_DOMAIN_NAME" '.[] | select(.nodeName + "." + .domainName == $name) | .id')

            if [ -z "$DNS_RECORD_ID" ]; then
                echo "Error: DNS record for $DYNU_DOMAIN_NAME not found."
                exit 1
            fi

            # Update the DNS record
            UPDATE_RESPONSE=$(update_dns_record $DOMAIN_ID $DNS_RECORD_ID $CURRENT_IPV4)
            echo "Update response: $UPDATE_RESPONSE"

            PREVIOUS_IPV4=$CURRENT_IPV4
        fi
        echo "CURRENT_IPV4: ${CURRENT_IPV4}"
        echo "DYNU_DOMAIN_NAME: ${DYNU_DOMAIN_NAME}"
        echo
    done
    sleep $POLLING_INTERVAL
done
