FROM bitnami/minideb:stretch

RUN install_packages openssl ca-certificates gnupg2 dirmngr curl

# Install supercronic
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.6/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=c3b78d342e5413ad39092fd3cfc083a85f5e2b75

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Install xtrabackup
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8507EFA5 && \
    echo "deb http://repo.percona.com/apt stretch main" >> /etc/apt/sources.list && \
    install_packages percona-xtrabackup qpress

# Install minio
RUN curl -fsSLO https://dl.minio.io/client/mc/release/linux-amd64/mc \
    && chmod +x ./mc \
    && mv ./mc /usr/local/bin/

WORKDIR /mnt

COPY config/crontab .
COPY scripts/xtrabackup.sh .
COPY scripts/extract_xtrabackup.sh .
COPY scripts/prepare_xtrabackup.sh .
COPY scripts/restore.sh .
RUN chmod +x xtrabackup.sh
RUN chmod +x extract_xtrabackup.sh
RUN chmod +x prepare_xtrabackup.sh
RUN chmod +x restore.sh


CMD ["bash", "-c", "/mnt/xtrabackup.sh"]
