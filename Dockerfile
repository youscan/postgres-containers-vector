ARG POSTGRESQL_VERSION=17-standard-bookworm
ARG EXTENSIONS="vchord-suite"
ARG VCHORD_VERSION=1.0.0
ARG VCHORD_BM25_VERSION=0.3.0
ARG PG_TOKENIZER_VERSION=0.1.1


FROM ghcr.io/cloudnative-pg/postgresql:${POSTGRESQL_VERSION}
ARG POSTGRESQL_VERSION
ARG EXTENSIONS
ENV EXTENSIONS=${EXTENSIONS}
ARG VCHORD_VERSION
ENV VCHORD_VERSION=${VCHORD_VERSION}
ARG VCHORD_BM25_VERSION
ENV VCHORD_BM25_VERSION=${VCHORD_BM25_VERSION}
ARG PG_TOKENIZER_VERSION
ENV PG_TOKENIZER_VERSION=${PG_TOKENIZER_VERSION}

COPY ./install_pg_extensions.sh /
USER root
RUN \
    usermod -u 999 postgres && \
    groupmod -g 999 postgres && \
    chown -R postgres:postgres /var/lib/postgresql && \
    export PG_MAJOR=$(echo "${POSTGRESQL_VERSION}" | sed 's/[^0-9].*//' ) && \
    apt-get update && \
    /install_pg_extensions.sh ${EXTENSIONS} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /install_pg_extensions.sh
USER postgres