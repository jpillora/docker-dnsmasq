FROM alpine:3.4
MAINTAINER dev@jpillora.com
# fetch programs
RUN apk update
RUN apk add --no-cache ca-certificates dnsmasq
# prepare go env
ENV VER 42
ENV PROG webproc
ENV PKG github.com/jpillora/$PROG
ENV GOLANG_VERSION 1.7.1
ENV GOLANG_SRC_URL https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz
ENV GOLANG_SRC_SHA256 2b843f133b81b7995f26d0cb64bbdbb9d0704b90c44df45f844d28881ad442d3
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# https://golang.org/issue/14851
COPY no-pic.patch /
# in one step (to prevent creating superfluous layers):
# 1. fetch and install temporary build programs,
# 2. build webproc alpine binary
# 3. remove build programs
RUN set -ex \
	&& apk add --no-cache --virtual .build-deps \
		bash \
		gcc \
		musl-dev \
		openssl \
		git \
		go \
	&& export GOROOT_BOOTSTRAP="$(go env GOROOT)" \
	&& wget -q "$GOLANG_SRC_URL" -O golang.tar.gz \
	&& echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz \
	&& cd /usr/local/go/src \
	&& patch -p2 -i /no-pic.patch \
	&& ./make.bash \
	&& go get -v $PKG \
	&& mv $GOPATH/bin/$PROG /usr/local/bin/ \
	&& apk del .build-deps \
	&& rm -rf /*.patch /go /usr/local/go
#configure dnsmasq
run mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
#run!
CMD ["webproc","--config","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]
