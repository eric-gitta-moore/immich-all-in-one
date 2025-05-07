#!/bin/bash

# CMD ["postgres", "-c" ,"shared_preload_libraries=vectors.so", "-c", "search_path=\"$user\", public, vectors", "-c", "logging_collector=on", "-c", "max_wal_size=2GB", "-c", "shared_buffers=512MB", "-c", "wal_compression=on"]

docker-entrypoint.sh postgres \
    -c shared_preload_libraries=vectors.so \
    -c search_path="\"\$user\", public, vectors" \
    -c logging_collector=on \
    -c max_wal_size=2GB \
    -c shared_buffers=512MB \
    -c wal_compression=on
