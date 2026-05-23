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
