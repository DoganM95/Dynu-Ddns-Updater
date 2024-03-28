# Dynu-Dns-Updater
Automatically updates a dynu ddns hostname's ipv4 address to the address of the machine it runs on, whenever it changes. 
- Default polling interval of 1 minute, needs a dynu account
- Free service used here `ipinfo.io/ip` has a rate limiting of 50k requests / month
- 60 Seond interval = max (31 * 24 * 3600) / 60 = 44640 requests / month

## Docker 

```shell
docker run \
    -e "DYNU_USERNAME=<dynu_username>" \
    -e "DYNU_PASSWORD=<dynu_password>" \
    -e "DYNU_HOSTNAME=<dynu_hostname>" \
    -e "POLLING_INTERVAL=<polling_interval>" \
    --restart=always \
    doganm95/dynu-ddns-updater
```

- Replace brackets `<>` and the text inside with your data:
  - `DYNU_USERNAME` (string): your dynu account username
  - `DYNU_PASSWORD` (string): your dynu password
  - `DYNU_HOSTNAME` (string): the hostname in your account to get its ipv4 address updated
  - `POLLING_INTERVAL` (uint): time in seconds to wait between each run
