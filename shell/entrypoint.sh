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
    echo "Checking IPv4 at $(date -Iseconds)"
    for SERVICE in $SERVICES; do
        response=$(curl -s "$SERVICE")
        CURRENT_IPV4=$(echo "$response" | tr -d '\n')

        if [ "$CURRENT_IPV4" != "$PREVIOUS_IPV4" ]; then
            echo "Updating IPv4 due to a change..."

            # Get the list of domains & extract the domain ID
            domains=$(get_domains)
            if [ -z "$domains" ]; then
                echo "Failed to fetch domains."
                continue
            fi

            domain_id=$(echo "$domains" | jq -r --arg name "$DYNU_DOMAIN_NAME" '.domains[] | select(.name == $name) | .id')
            if [ -z "$domain_id" ]; then
                echo "Error: Domain ID for $DYNU_DOMAIN_NAME not found."
                exit 1
            fi

            sleep 1 # Wait to not get hit by rate limiter

            # Update the DNS service
            res_status=$(update_dns_service "$domain_id" "$CURRENT_IPV4" null)
            if [ "$res_status" = "200" ]; then
                echo "Successfully updated IPv4 from $PREVIOUS_IPV4 to $CURRENT_IPV4 for domain $DYNU_DOMAIN_NAME"
                PREVIOUS_IPV4="$CURRENT_IPV4"
            else
                echo "Failed to update the IPv4 with status code $res_status"
            fi
        fi
    done
    sleep "$POLLING_INTERVAL" # Interval in seconds
done
