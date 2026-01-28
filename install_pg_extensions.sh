#!/bin/bash
set -euxo pipefail

# calling syntax: install_pg_extensions.sh [extension1] [extension2] ...

# install extensions
EXTENSIONS="$@"
ARCH=$(dpkg --print-architecture)

# cycle through extensions list
for EXTENSION in ${EXTENSIONS}; do
    if [ "$EXTENSION" == "vchord-suite" ]; then
        apt-get install -y wget postgresql-${PG_MAJOR}-pgvector

        wget -q https://github.com/tensorchord/VectorChord/releases/download/${VCHORD_VERSION}/postgresql-${PG_MAJOR}-vchord_${VCHORD_VERSION}-1_${ARCH}.deb
        apt-get install -y ./postgresql-${PG_MAJOR}-vchord_${VCHORD_VERSION}-1_${ARCH}.deb

        wget -q https://github.com/tensorchord/VectorChord-bm25/releases/download/${VCHORD_BM25_VERSION}/postgresql-${PG_MAJOR}-vchord-bm25_${VCHORD_BM25_VERSION}-1_${ARCH}.deb
        apt-get install -y ./postgresql-${PG_MAJOR}-vchord-bm25_${VCHORD_BM25_VERSION}-1_${ARCH}.deb

        wget -q https://github.com/tensorchord/pg_tokenizer.rs/releases/download/${PG_TOKENIZER_VERSION}/postgresql-${PG_MAJOR}-pg-tokenizer_${PG_TOKENIZER_VERSION}-1_${ARCH}.deb
        apt-get install -y ./postgresql-${PG_MAJOR}-pg-tokenizer_${PG_TOKENIZER_VERSION}-1_${ARCH}.deb

        rm -f *.deb
        apt-get remove wget --auto-remove -y

        continue
    fi

    # is it an extension found in apt?
    if apt-cache show "postgresql-${PG_MAJOR}-${EXTENSION}" &> /dev/null; then
        # install the extension
        apt-get install -y "postgresql-${PG_MAJOR}-${EXTENSION}"
        continue
    fi

    # extension not found/supported
    echo "Extension '${EXTENSION}' not found/supported"
    exit 1
done
