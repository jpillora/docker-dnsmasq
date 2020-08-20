FROM alpine:edge
LABEL maintainer="dev@jpillora.com"

ENV DNSMASQ_VERSION 2.82-r0

# webproc release settings
ENV WEBPROC_VERSION 0.2.2
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/$WEBPROC_VERSION/webproc_linux_amd64.gz
# fetch dnsmasq and webproc binary
RUN apk update \
	&& apk --no-cache add dnsmasq=$DNSMASQ_VERSION \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& apk del .build-deps
#configure dnsmasq
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
#run!
ENTRYPOINT ["webproc","--config","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]
