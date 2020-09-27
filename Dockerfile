FROM alpine:3.11

LABEL maintainer="armand <armsultan@gmail.com>"

# If TZ is not passed as a build arg, go with UTC
# e.g. TZ=America/Denver
ARG TZ=UTC
ENV VERSION="3.22.1-r2"

RUN apk add --no-cache \
    # Uncomment one. Install syslog-ng Latest or specific version:
    # syslog-ng \
    syslog-ng=${VERSION} \
    glib \
    pcre \
    eventlog \
    openssl \
    tini \
    && apk add --no-cache --virtual .build-deps \
    curl \
    alpine-sdk \
    glib-dev \
    pcre-dev \
    eventlog-dev \
    openssl-dev \
    tzdata \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && rm -rf /tmp/* \
    && apk del --no-cache .build-deps \
    && mkdir -p /etc/syslog-ng /var/run/syslog-ng /var/log/syslog-ng
    
COPY syslog-ng.conf /etc/syslog-ng

VOLUME ["/var/log/syslog-ng", "/var/run/syslog-ng", "/etc/syslog-ng"]

EXPOSE 514/udp 601/tcp 6514/tcp

ENTRYPOINT ["tini", "--"]

CMD ["/bin/sh", "-c", "exec /usr/sbin/syslog-ng -F -f /etc/syslog-ng/syslog-ng.conf"]