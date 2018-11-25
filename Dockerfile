FROM anapsix/alpine-java:8u192b12_jdk_unlimited

MAINTAINER thiagodiogo@gmail.com

ENV PRESTO_VERSION 0.214
ENV DOCKERIZE_VERSION v0.2.0

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
    wget \
    perl \
    less \
    && rm -rf /var/cache/apk/*

RUN apk add --no-cache util-linux

RUN pip install crudini && \
    wget https://repo1.maven.org/maven2/com/facebook/presto/presto-server/$PRESTO_VERSION/presto-server-$PRESTO_VERSION.tar.gz -O /tmp/presto.tar.gz && \
    mkdir /opt/presto && \
    tar -zxvf /tmp/presto.tar.gz -C /opt/presto --strip-components=1 && \
    rm /tmp/presto.tar.gz && \
    wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$PRESTO_VERSION/presto-cli-$PRESTO_VERSION-executable.jar -O /usr/local/bin/presto-cli && \
    chmod +x /usr/local/bin/presto-cli && \
    wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz


COPY resources/etc/* /opt/presto/etc/
ADD resources/etc/catalog/hive.properties /opt/presto/etc/catalog/hive.properties
ADD resources/entrypoint.sh entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]
CMD ["/opt/presto/bin/launcher", "run"]
