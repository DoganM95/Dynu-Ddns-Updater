# Intro

Automatically updates a dynu ddns hostname's ipv4 address to the address of the machine it runs on, whenever it changes.  

- Default polling interval of 1 minute, needs a dynu account
- Free service used here `ipinfo.io/ip` has a rate limiting of 50k requests / month
- 60 Seond interval = `max (31 * 24 * 3600) / 60` = `44640 requests / month`

## Variants

There are two variants of this thing, but using the shell one is highly recommended.

### Javascript

A debuggable version, created only to ease the development process and having a quickly debuggable code on windows. 
Specs of the image:
- Name: `dynu-ddns-updater-js`
- Size: `152 MB`

### Shell

The derived script off the javascript variant, for production use. Lightweight and goes easy on the resources.
Specs of the image:
- Name: `dynu-ddns-updater-shell`
- Size: `17 MB`

## Docker

### Linux

```shell
docker run \
    -e "DYNU_API_KEY=<key>" \
    -e "DYNU_DOMAIN_NAME=<domain>" \
    -e "POLLING_INTERVAL=<interval>" \
    --pull=always \
    --restart=always \
    ghcr.io/doganm95/dynu-ddns-updater-<variant>:latest
```

### WIndows

```powershell
docker run `
    -e "DYNU_API_KEY=<key>" `
    -e "DYNU_DOMAIN_NAME=<domain>" `
    -e "POLLING_INTERVAL=<interval>" `
    --pull=always `
    --restart=always `
    ghcr.io/doganm95/dynu-ddns-updater-<variant>:latest
```

- Replace brackets `<>` and the text inside with your data:
  - `DYNU_API_KEY` (string): your [dynu api key](https://www.dynu.com/en-US/ControlPanel/APICredentials), authorizing the rest calls
  - `DYNU_DOMAIN_NAME` (string): the hostname in your account to get its ipv4 address updated
  - `POLLING_INTERVAL` (uint): time in seconds to wait between each run
  - `variant` (string): the language base of the code, can be `shell` or `js`
