FROM alpine:latest

LABEL maintainer="dev@jpillora.com"

# expose ports
EXPOSE 53
EXPOSE 8080

# fetch dnsmasq and webproc binary
RUN apk update && \
	apk --no-cache add dnsmasq bash && \
	apk add --no-cache --virtual .build-deps curl && \
	curl -sL https://i.jpillora.com/webproc | bash && \
	apk del .build-deps && \
	mv webproc /usr/local/bin/ && \
	\
	mkdir -p /etc/default/ && \
	echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq

#configure dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf

#run!
ENTRYPOINT [ "webproc", "--configuration-file", "/etc/dnsmasq.conf", "--", "dnsmasq", "--no-daemon" ]
