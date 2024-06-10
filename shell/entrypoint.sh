#!/bin/sh

SERVICES="http://ipinfo.io/ip" # Add services into existing string, separated by space

# Function to get the list of domains
get_domains() {
    curl -s -X GET "https://api.dynu.com/v2/dns" \
        -H "accept: application/json" \
        -H "API-Key: $DYNU_API_KEY"
}

# Function to update DNS service
update_dns_service() {
    local id=$1
    local new_ipv4=$2
    local new_ipv6=$3

    curl -s -X POST "https://api.dynu.com/v2/dns/$id" \
        -H "accept: application/json" \
        -H "API-Key: $DYNU_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "'"$DYNU_DOMAIN_NAME"'",
            "ipv4Address": "'"$new_ipv4"'",
            "ipv6Address": '"${new_ipv6:-null}"',
            "ipv4": true,
            "ipv6": true
        }' | jq -r '.statusCode'
}

while true; do
    for SERVICE in $SERVICES; do
        CURRENT_IPV4=$(curl -s "$SERVICE")
        if [ "$CURRENT_IPV4" != "$PREVIOUS_IPV4" ]; then
            echo "Updating IPV4 from $PREVIOUS_IPV4 to $CURRENT_IPV4"
            echo # \n

            # Get the list of domains & extract the domain ID
            DOMAINS=$(get_domains)
            DOMAIN_ID=$(echo $DOMAINS | jq -r --arg name "$DYNU_DOMAIN_NAME" '.domains[] | select(.name == $name) | .id')

            if [ -z "$DOMAIN_ID" ]; then
                echo "Error: Domain ID for $DYNU_DOMAIN_NAME not found."
                exit 1
            fi

            # Get DNS records & extract record ID for given domain name
            DNS_RECORDS=$(get_dns_records $DOMAIN_ID)
            echo "DNS_RECORDS: $DNS_RECORDS"

            DNS_RECORD_ID=$(echo $DNS_RECORDS | jq -r --arg name "$DYNU_DOMAIN_NAME" '.dnsRecords[] | select(.hostname == $name and .recordType == "A") | .id')

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
