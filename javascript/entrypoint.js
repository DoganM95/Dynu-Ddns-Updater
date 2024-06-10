const axios = require("axios");
const dotenv = require("dotenv").config({ path: `${__dirname}/.env` });

// Environment variables
const DYNU_API_KEY = process.env.DYNU_API_KEY;
const DYNU_DOMAIN_NAME = process.env.DYNU_DOMAIN_NAME;
const POLLING_INTERVAL = process.env.POLLING_INTERVAL || 60000; // Default: 1 minute

const SERVICES = ["http://ipinfo.io/ip"];
let PREVIOUS_IPV4 = "";

const sleep = (ms) => {
    return new Promise((resolve) => setTimeout(resolve, ms));
};

// Function to get the list of domains
const getDomains = async () => {
    try {
        const response = await axios.get("https://api.dynu.com/v2/dns", {
            headers: {
                accept: "application/json",
                "API-Key": DYNU_API_KEY,
            },
        });
        return response.data;
    } catch (error) {
        console.error("Error fetching domains:", error);
        return null;
    }
};

// Function to update DNS service
const updateDnsService = async (id, newIpv4, newIpv6) => {
    try {
        const response = await axios.post(
            `https://api.dynu.com/v2/dns/${id}`,
            {
                name: DYNU_DOMAIN_NAME.trim(),
                ipv4Address: newIpv4.trim(),
                ipv6Address: newIpv6 ?? null,
                ipv4: true,
                ipv6: true,
            },
            {
                headers: {
                    accept: "application/json",
                    "API-Key": DYNU_API_KEY,
                    "Content-Type": "application/json",
                },
            },
        );
        return response.status;
    } catch (error) {
        console.error(`Error updating DNS record ID ${dnsRecordId} for domain ID ${id}:`, error);
        return error.response.status;
    }
};

// Main loop
let mutex = false;
const mainLoop = async () => {
    try {
        if (!mutex) {
            mutex = true;
            console.log(`Checking ipv4 at ${Date.now()}`);
            for (const SERVICE of SERVICES) {
                const response = await axios.get(SERVICE);
                const CURRENT_IPV4 = response.data.trim();

                if (CURRENT_IPV4 != PREVIOUS_IPV4) {
                    console.log(`Updating ipv4 due to a change...`);

                    // Get the list of domains & extract the domain ID
                    const domains = await getDomains();
                    const domain = domains.domains.find((d) => d.name === DYNU_DOMAIN_NAME);
                    if (!domain) {
                        console.error(`Error: Domain ID for ${DYNU_DOMAIN_NAME} not found.`);
                        process.exit(1);
                    }
                    const domainId = domain.id;
                    await sleep(1000);

                    // Update the DNS service
                    const resStatus = await updateDnsService(domainId, CURRENT_IPV4, null);
                    if (resStatus == 200) {
                        console.log(`Successfully updated IPV4 from ${PREVIOUS_IPV4} to ${CURRENT_IPV4} for domain ${DYNU_DOMAIN_NAME}`);
                        PREVIOUS_IPV4 = CURRENT_IPV4;
                    } else {
                        console.error(`Failed to update the ipv4 with status code ${resStatus}`);
                    }
                }
            }
            mutex = false;
        }
    } catch (error) {
        console.error(`Error in main loop for service ${SERVICE}:`, error);
    }
};

// Start the polling loop
setInterval(mainLoop, POLLING_INTERVAL);
mainLoop();
