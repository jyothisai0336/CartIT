# Stage 1 — Build React app
FROM node:20-alpine AS builder
WORKDIR /app
COPY app/package.json app/package-lock.json ./
RUN npm ci --frozen-lockfile
COPY app/ .
RUN npm run build

# Stage 2 — Serve with nginx (non-root, hardened)
FROM nginx:1.25-alpine AS production
RUN addgroup -g 1001 -S cartit && adduser -u 1001 -S cartit -G cartit
COPY devops/docker/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/build /usr/share/nginx/html
RUN chown -R cartit:cartit /usr/share/nginx/html /var/cache/nginx && \
    touch /var/run/nginx.pid && chown cartit:cartit /var/run/nginx.pid
USER cartit
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8080/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
