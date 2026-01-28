# PostgreSQL container images with vchord-suite

This repository contains dockerfiles, scripts, and GitHub Actions to extend PostgreSQL container images from [ghcr.io/cloudnative-pg/postgresql](https://github.com/cloudnative-pg/postgres-containers/) with [vchord-suite](https://docs.vectorchord.ai/) for hybrid vector and full-text search.

## Included Extensions

- **vchord** - scalable vector similarity search (successor to pgvecto.rs)
- **vchord_bm25** - BM25 full-text search ranking
- **pg_tokenizer** - text tokenization for multilingual BM25 search
- **pgvector** - vector data type (dependency for vchord)

## Building locally

```shell
docker build -t postgresql-vchord .
```

By default the image uses PostgreSQL 17 on Debian Bookworm. You can customize with build arguments:

```shell
docker build -t postgresql-vchord \
  --build-arg POSTGRESQL_VERSION=16-standard-bookworm \
  --build-arg VCHORD_VERSION=1.0.0 \
  --build-arg VCHORD_BM25_VERSION=0.3.0 \
  --build-arg PG_TOKENIZER_VERSION=0.1.1 \
  .
```

Additional APT extensions can be added:

```shell
docker build -t postgresql-vchord --build-arg EXTENSIONS="vchord-suite cron" .
```

## CloudNativePG Configuration

When using with CloudNativePG, configure `shared_preload_libraries`:

```yaml
postgresql:
  shared_preload_libraries:
    - vchord
    - pg_tokenizer
```

Then create extensions:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS vchord CASCADE;
CREATE EXTENSION IF NOT EXISTS pg_tokenizer CASCADE;
CREATE EXTENSION IF NOT EXISTS vchord_bm25 CASCADE;
```

## Building with GitHub Actions

The repository includes a GitHub Actions workflow that builds and pushes images to `ghcr.io/<repository_owner>/postgresql`. The workflow is triggered manually and accepts version inputs.

Image tags follow the format: `<pg-version>-<extensions>`, for example: `17-standard-bookworm-vchord-suite`

## Requirements

- Base image must be Bookworm-based (Debian 12) for glibc >= 2.35 compatibility
- vchord-suite supports PostgreSQL 14-18
