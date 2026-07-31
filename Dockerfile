FROM justarchi/archisteamfarm:stable

USER root

COPY plugins/PersonalAccountManager/ /app/plugins/PersonalAccountManager/
COPY start-railway.sh /usr/local/bin/start-railway.sh

RUN chmod 0755 /usr/local/bin/start-railway.sh \
    && mkdir -p /app/config /app/plugins/PersonalAccountManager \
    && chown -R 1000:1000 /app/config /app/plugins

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/start-railway.sh"]