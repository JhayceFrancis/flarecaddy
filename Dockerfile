# Stage 1: Build the custom binary
FROM caddy:builder-alpine AS builder

# Compile Caddy with the Cloudflare DNS module
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

# Stage 2: Construct the final lightweight image
FROM caddy:alpine

# Bring over the compiled binary
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Set up healthchecks to ensure the container auto-recovers if the routing engine hangs
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:2019/metrics || exit 1

# Copy your global configuration (we will structure this next)
COPY Caddyfile /etc/caddy/Caddyfile
COPY conf.d/ /etc/caddy/conf.d/
COPY flarecaddy.png /usr/share/caddy/flarecaddy.png
