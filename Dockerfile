FROM --platform=$BUILDPLATFORM alpine:latest AS build
# arguments
ARG TARGETOS TARGETARCH
# webproc release settings
ENV WEBPROC_VERSION 0.4.0
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_${TARGETOS}_${TARGETARCH}.gz
# fetch webproc binary
RUN apk --no-cache --virtual .build-deps add curl \
    && curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
    && apk del .build-deps

FROM alpine:latest
LABEL maintainer="dev@jpillora.com"
ENV HTTP_USER admin
ENV HTTP_PASS password
# fetch dnsmasq binary
RUN apk update \
    && apk --no-cache add dnsmasq
# copy webproc binary
COPY --from=build /usr/local/bin/webproc /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc
# configure dnsmasq
RUN mkdir -p /etc/default/ \
    && echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
# run!
EXPOSE 53/udp
EXPOSE 8080
ENTRYPOINT ["webproc","--configuration-file","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]
