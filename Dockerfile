FROM alpine:edge
LABEL maintainer="dev@jpillora.com"
# webproc release settings
ENV GITHUB_URL 'https://api.github.com/repos/jpillora/webproc/releases/latest'
ENV JQ_SCRIPT '.assets[] | select(.browser_download_url | contains("linux_amd64")).browser_download_url'

# fetch dnsmasq and webproc binary
RUN apk update \
	&& apk --no-cache add dnsmasq \
	&& apk add --no-cache --virtual .build-deps curl jq \
	&& curl -sL $GITHUB_URL | jq -r "$JQ_SCRIPT" | xargs -I% curl -sL % | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& apk del .build-deps
#configure dnsmasq
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
#run!
ENTRYPOINT ["webproc","--config","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]
