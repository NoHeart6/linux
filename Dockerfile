FROM node:22-trixie-slim
ENV DEBIAN_FRONTEND=noninteractive HOME=/root NODE_ENV=production
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl git wget nginx apache2-utils supervisor tini \
    sqlite3 python3 procps openssl xz-utils && rm -rf /var/lib/apt/lists/*
RUN curl -fL --retry 3 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd
RUN npm install -g opencode-ai@latest 9router@0.5.99 && npm cache clean --force
COPY entrypoint.sh /usr/local/bin/railway-entrypoint
COPY run-ttyd.sh /usr/local/bin/run-ttyd
COPY nginx.conf.template /etc/nginx/templates/railway.conf.template
COPY supervisord.conf /etc/supervisor/conf.d/railway.conf
RUN chmod 755 /usr/local/bin/railway-entrypoint /usr/local/bin/run-ttyd && rm -f /etc/nginx/sites-enabled/default
ENV PORT=8080 USERNAME=admin
EXPOSE 8080 20128
WORKDIR /root
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/usr/local/bin/railway-entrypoint"]
