FROM ubuntu:14.04
MAINTAINER dev@jpillora.com

RUN apt-get update
RUN apt-get install -y dnsmasq supervisor

RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p     /agent
ADD agent/static /agent/static
ADD agentd       /agent/agentd
RUN chmod +x     /agent/agentd

EXPOSE 53 8080

CMD ["/usr/bin/supervisord"]