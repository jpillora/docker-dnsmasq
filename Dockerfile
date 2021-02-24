FROM alpine:3.13
LABEL maintainer="dev@jpillora.com"

ENV WEBPROC_VERSION 0.4.0

RUN apk update \
	&& apk --no-cache add dnsmasq-dnssec \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL "https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_amd64.gz" | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& apk del .build-deps

RUN echo $'# Use CloudFlare NS Servers\n\
server=1.0.0.1\n\
server=1.1.1.1\n# Serve all .company queries using a specific nameserver\n\
server=/company/10.0.0.1\n# Define Hosts DNS Records\n\
address=/myhost.company/10.0.0.2\n' > /etc/dnsmasq.conf

ENTRYPOINT ["webproc", "-c", "/etc/dnsmasq.conf", "-c", "/etc/hosts", "--", "dnsmasq", "--keep-in-foreground", "--log-queries", "--no-resolv", "--strict-order"]
