ARG FROM_TAG=pg16-v0.4.0
ARG POSTGRES_VERSION=16
FROM scratch AS nothing
ARG TARGETARCH=amd64
FROM tensorchord/pgvecto-rs-binary:${FROM_TAG}-${TARGETARCH} AS binary

#region zhparser
FROM postgres:${POSTGRES_VERSION}-bookworm AS builder

ARG DEBIAN_FRONTEND=noninteractive
RUN set -ex \
    && apt-get update \
    && apt-get install -y build-essential git postgresql-server-dev-${PG_MAJOR} pkg-config binutils automake libtool \
    && apt-get clean

RUN set -ex \
    && git clone --branch 1.2.3 --single-branch --depth 1 https://github.com/hightman/scws.git \
    && cd scws \
    && touch README;aclocal;autoconf;autoheader;libtoolize;automake --add-missing \
    && ./configure \
    && make install

RUN set -ex \
    && git clone --branch master --single-branch --depth 1 https://github.com/amutu/zhparser.git \
    && cd zhparser \
    && make install

FROM postgres:${POSTGRES_VERSION}-bookworm AS prod
RUN localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.UTF-8

COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/zhparser.so /usr/lib/postgresql/${PG_MAJOR}/lib/
COPY --from=builder /usr/local/lib/libscws.* /usr/local/lib/
COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/zhparser* /usr/share/postgresql/${PG_MAJOR}/extension/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/zhparser* /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/
COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/tsearch_data/*.utf8.* /usr/share/postgresql/${PG_MAJOR}/tsearch_data/
#endregion zhparser

COPY --from=binary /pgvecto-rs-binary-release.deb /tmp/vectors.deb
RUN apt-get install -y /tmp/vectors.deb && rm -f /tmp/vectors.deb

EXPOSE 5432
VOLUME [ "/var/lib/postgresql/data" ]
CMD ["postgres", "-c" ,"shared_preload_libraries=vectors.so", "-c", "search_path=\"$user\", public, vectors", "-c", "logging_collector=on"]