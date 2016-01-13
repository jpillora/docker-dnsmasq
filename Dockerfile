FROM debian:jessie
MAINTAINER dev@jpillora.com
USER root
#configure golang
ENV GOPATH /root/go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin
#copy over dnsmasq agent src
ADD agent /agent
#all installs then uninstalls in one! (docker has no ability to squash commits)
RUN apt-get update && apt-get install --no-install-recommends -y dnsmasq ca-certificates curl supervisor && \
	curl -s https://storage.googleapis.com/golang/go1.5.2.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
	cd /agent && go build -o agentd && \
	rm -rf /root/go && \
	rm -rf /usr/local/go && \
	apt-get remove --purge -y curl && \
	apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*
#configure dnsmasq
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
#configure supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#run!
CMD ["/usr/bin/supervisord"]
