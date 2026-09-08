
const dns = require("dns");

dns.setServers([
    "8.8.8.8",
    "8.8.4.4"
]);

dns.resolveSrv(
    "_mongodb._tcp.cluster0.hgqrtvl.mongodb.net",
    (error, records) => {
        if (error) {
            console.error("DNS ERROR:", error);
        } else {
            console.log("DNS SUCCESS:", records);
        }
    }
);