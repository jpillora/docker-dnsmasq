FROM ubuntu

RUN apt-get update
RUN apt-get install -y dnsmasq

EXPOSE 53 8080

ADD agent     /agent
RUN chmod +x  /agent/agentd
RUN chmod +x  /agent/run.sh

WORKDIR /agent/

CMD ["/bin/bash","run.sh"]