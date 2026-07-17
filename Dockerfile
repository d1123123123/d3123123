FROM justarchi/archisteamfarm:latest

USER root
COPY start-railway.sh /usr/local/bin/start-railway.sh
RUN chmod 0755 /usr/local/bin/start-railway.sh \
    && mkdir -p /app/config \
    && chown -R 1000:1000 /app/config

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/start-railway.sh"]
