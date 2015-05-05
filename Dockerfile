FROM ubuntu:14.04
MAINTAINER dev@jpillora.com
#apt-gets
RUN apt-get update
RUN apt-get install -y dnsmasq supervisor wget
#configure dnsmasq
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
#configure supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#golang install
RUN /usr/bin/wget -qO- https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV GOPATH /root/go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin
#copy over dnsmasq agent
ADD agent /agent
#compile it
RUN cd /agent && go build -o agentd
#run supervisor!
CMD ["/usr/bin/supervisord"]