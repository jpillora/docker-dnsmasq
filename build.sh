#!/bin/bash
cd agent &&
go build -o ../agentd &&
cd .. &&
docker build --rm -t jpillora/dnsmasq:1.0.0 .
