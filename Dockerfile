FROM ubuntu

RUN apt-get update
RUN apt-get install -y dnsmasq

CMD ["service dnsmasq restart && /bin/bash"]

# EXPOSE 53

# RUN mkdir /app
# ADD dnsmasq.conf /app/dnsmasq.conf
# ADD agent/static/ /app/static/
# ADD agentd /app/agentd
# RUN chmod +x /usr/local/bin/agentd

# WORKDIR /app/

# CMD ["./agentd"]