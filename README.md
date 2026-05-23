# 🚀 Flarecaddy

A custom, lightweight [Caddy](https://caddyserver.com/) Docker container pre-compiled with the **Cloudflare DNS plugin** (`caddy-dns/cloudflare`). 

Designed for homelabs and self-hosted server environments, Flarecaddy enables automated Let's Encrypt wildcard SSL certificate generation via DNS challenges. This allows you to secure your internal services with valid, publicly trusted HTTPS certificates without ever exposing ports 80 or 443 to the open internet.

---

## ✨ Why Flarecaddy?

The official Caddy Docker image is fantastic, but it does not include DNS-provider plugins out of the box. If your server is isolated behind a strict firewall or a mesh VPN (like Tailscale), standard HTTP challenges for SSL certificates will fail because Certificate Authorities cannot reach your machine.

Flarecaddy solves this by automating the `xcaddy` build process. It leverages your Cloudflare API token to securely verify domain ownership behind the scenes, ensuring smooth, automated certificate provisioning and renewals for local, zero-trust deployments.

---

## 🛠 Deployment

Flarecaddy functions identically to the official Caddy image, requiring only the addition of your Cloudflare API token as an environment variable.

### Docker Compose

Deploy the stack using the following `docker-compose.yml` file:

```yaml
services:
  flarecaddy:
    image: ghcr.io/jhaycefrancis/flarecaddy:latest
    container_name: flarecaddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp" # Required for HTTP/3
    environment:
      - CLOUDFLARE_API_TOKEN=your_secure_api_token_here
    volumes:
      - /path/to/Caddyfile:/etc/caddy/Caddyfile:ro
      - /path/to/caddy_data:/data
      - /path/to/caddy_config:/config
```
---

### Unraid Installation

If deploying via Unraid, set up the container with the following mappings:

Repository: ```ghcr.io/jhaycefrancis/flarecaddy:latest```

Network Type: ```bridge``` or a custom Docker network.

Ports: Map ```80``` and ```443``` (TCP/UDP) appropriately.

Variable: Add a variable named ```CLOUDFLARE_API_TOKEN``` and input your token.

Paths:

  * Map ```/etc/caddy/Caddyfile directly``` to your local Caddyfile.

  * Map ```/data``` to your appdata directory to ensure your generated SSL certificates remain persistent across reboots.


---

### Example Caddyfile
Here is a template demonstrating how to structure your Caddyfile to utilise the Cloudflare DNS module for a wildcard domain. Note the required ```tls``` block configuration.
```Caddyfile
# Global Block
{
    email your_email@domain.com
}

# The Wildcard Block: Secures everything under your domain
*.yourdomain.com {
    tls {
        # Instructs Caddy to use the Cloudflare API for domain verification
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        resolvers 1.1.1.1
        propagation_timeout -1
        propagation_delay 60s
    }

    # Example internal routing (Must use internal container ports on a shared Docker network)
    @example host app.yourdomain.com
    handle @example {
        reverse_proxy app_container_name:8080
    }
    
    # Catch-All Security: Drops requests to undefined subdomains
    handle {
        abort
    }
}
```
---

## 🔒 Security Best Practices

* API Tokens: Never use a Global API Key. Always generate a restricted Cloudflare API Token with strictly the Zone:DNS:Edit permissions for the specific zones you intend to route.

* Persistent Storage: Always mount the /data directory. Caddy stores your Let's Encrypt certificates here. Failing to mount this volume will result in Caddy requesting new certificates upon every container restart, which will quickly trigger Let's Encrypt rate limits.

* Internal Routing: When reverse proxying to other containers on the same Docker bridge network, always specify the target container's internal, hardcoded port rather than the external host port.
---

## 🤝 Contributing & Licensing

Contributions, issues, and feature requests are welcome. Feel free to check the issues page if you want to contribute.

This project is licensed under the MIT License.

---
