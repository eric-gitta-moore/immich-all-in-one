#!/bin/bash

pg_isready --dbname="$POSTGRES_DB" --username="$POSTGRES_USER" || exit 1
Chksum="$(psql --dbname="$POSTGRES_DB" --username="$POSTGRES_USER" --tuples-only --no-align \
    --command='SELECT COALESCE(SUM(checksum_failures), 0) FROM pg_stat_database')"
echo "checksum failure count is $Chksum"
[ "$Chksum" = '0' ] || exit 1
