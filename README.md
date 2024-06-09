# Dynu-Dns-Updater

Automatically updates a dynu ddns hostname's ipv4 address to the address of the machine it runs on, whenever it changes.

- Default polling interval of 1 minute, needs a dynu account
- Free service used here `ipinfo.io/ip` has a rate limiting of 50k requests / month
- 60 Seond interval = `max (31 * 24 * 3600) / 60` = `44640 requests / month`

## Docker

### Linux

```shell
docker run \
    -e "DYNU_API_KEY=<key>" \
    -e "DYNU_DOMAIN_NAME=<domain>" \
    -e "POLLING_INTERVAL=<interval>" \
    --restart=always \
    doganm95/dynu-ddns-updater
```

### WIndows

```powershell
docker run `
    -e "DYNU_API_KEY=<key>" `
    -e "DYNU_DOMAIN_NAME=<domain>" `
    -e "POLLING_INTERVAL=<interval>" `
    --restart=always `
    doganm95/dynu-ddns-updater
```

- Replace brackets `<>` and the text inside with your data:
  - `DYNU_API_KEY` (string): your dynu api key, authorizing the rest calls
  - `DYNU_DOMAIN_NAME` (string): the hostname in your account to get its ipv4 address updated
  - `POLLING_INTERVAL` (uint): time in seconds to wait between each run
