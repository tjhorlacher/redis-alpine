FROM alpine:latest

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE\
      org.label-schema.version=latest\
      org.label-schema.vcs-url="https://github.com/tjhorlacher/redis-alpine.git"\
      org.label-schema.vcs-ref=$VCS_REF\
      org.label-schema.name="Redis Alpine Image"\
      org.label-schema.usage="https://github.com/tjhorlacher/redis-alpine"\
      org.label-schema.schema-version="1.0.0"

RUN addgroup -S redis && adduser -S -G redis redis\
 && mkdir -p /redis/data /redis/modules\
 && chown redis:redis /redis/data /redis/modules

RUN apk upgrade --update-cache --available
RUN set -x\
 && apk add --virtual .build-deps\
  curl\
  gcc\
  linux-headers\
  make\
  musl-dev\
  tar\
 && curl -o redis.tar.gz http://download.redis.io/releases/redis-stable.tar.gz\
 && mkdir -p /usr/src/redis\
 && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1\
 && rm redis.tar.gz\
 && make -C /usr/src/redis\
 && make -C /usr/src/redis install\
 && rm -r /usr/src/redis\
 && apk del .build-deps

VOLUME /redis/modules
VOLUME /redis/data

WORKDIR /redis/data
USER redis

ENTRYPOINT ["redis-server"]
CMD ["--help"]