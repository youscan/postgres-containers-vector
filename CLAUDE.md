# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project builds Docker container images that extend CloudNative PG PostgreSQL images with vchord-suite for hybrid vector and full-text search. Designed for use with the CloudNative PG Kubernetes operator.

**Base image:** `ghcr.io/cloudnative-pg/postgresql:17-standard-bookworm`

**Extensions included in vchord-suite:**

- `vchord` - vector similarity search (requires pgvector)
- `vchord_bm25` - BM25 full-text search ranking
- `pg_tokenizer` - text tokenization for BM25

## Build Commands

Build locally with defaults:

```bash
docker build -t postgresql-vchord .
```

Build with custom versions:

```bash
docker build -t postgresql-vchord \
  --build-arg POSTGRESQL_VERSION=16-standard-bookworm \
  --build-arg VCHORD_VERSION=1.0.0 \
  --build-arg VCHORD_BM25_VERSION=0.3.0 \
  --build-arg PG_TOKENIZER_VERSION=0.1.1 \
  .
```

## Testing the Build

```bash
docker run --rm -e PGDATA=/tmp/pgdata postgresql-vchord bash -c '
  initdb -D /tmp/pgdata
  echo "shared_preload_libraries = '\''vchord,pg_tokenizer'\''" >> /tmp/pgdata/postgresql.conf
  pg_ctl -D /tmp/pgdata start
  sleep 2
  psql -c "CREATE EXTENSION vector; CREATE EXTENSION vchord CASCADE; CREATE EXTENSION pg_tokenizer CASCADE; CREATE EXTENSION vchord_bm25 CASCADE;"
  psql -c "SELECT extname, extversion FROM pg_extension;"
'
```

## Architecture

1. **Dockerfile** - Extends CloudNative PG base image, extracts `PG_MAJOR` from version string, runs extension installer as root
2. **install_pg_extensions.sh** - Handles extension installation:

   - `vchord-suite`: Downloads .deb packages from GitHub releases for vchord, vchord_bm25, pg_tokenizer; also installs pgvector from APT
   - Other extensions: Uses standard Debian APT packages named `postgresql-${PG_MAJOR}-${extension}`
3. **GitHub Actions workflow** - Manual workflow that builds and pushes to `ghcr.io/<owner>/postgresql` with tags like `17-standard-bookworm-vchord-suite`

## CloudNativePG Configuration

When deploying with CloudNativePG, configure shared_preload_libraries:

```yaml
postgresql:
  shared_preload_libraries:
    - vchord
    - pg_tokenizer
```

Note: `vchord_bm25` does NOT require shared_preload_libraries.

## Important Notes

- Base image must be Bookworm-based (Debian 12) for glibc >= 2.35 compatibility
- vchord-suite supports PostgreSQL 14-18
