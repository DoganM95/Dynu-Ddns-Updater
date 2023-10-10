# Build
docker build -t doganm95/dynu-ddns-updater .

# Run
docker run \
    -d \
    -e "DYNU_USERNAME=User" \
    -e "DYNU_PASSWORD=Pass" \
    -e "DYNU_HOSTNAME=Host" \
    -e "POLLING_INTERVAL=60" \
    doganm95/dynu-ddns-updater
