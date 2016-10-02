
# docker-dnsmasq

dnsmasq in a docker container, configurable via a [simple web UI](https://github.com/jpillora/webproc)

[![Docker Pulls](https://img.shields.io/docker/pulls/jpillora/dnsmasq.svg)][dockerhub]
[![Image Size](https://img.shields.io/badge/docker%20image-11.76%20MB-blue.svg)][dockerhub]

<!--
no stars yet :(
[![Docker Stars](https://img.shields.io/docker/stars/jpillora/dnsmasq.svg)][dockerhub]
-->

### Usage

1. Create a [`/opt/dnsmasq.conf`](http://oss.segetech.com/intra/srv/dnsmasq.conf) file on the Docker host

	``` ini
	#dnsmasq config, for a complete example, see:
	#  http://oss.segetech.com/intra/srv/dnsmasq.conf
	#log all dns queries
	log-queries
	#dont use hosts nameservers
	no-resolv
	#use google as default nameservers
	server=8.8.4.4
	server=8.8.8.8
	#serve all .company queries using a specific nameserver
	server=/company/10.0.0.1
	#explicitly define host-ip mappings
	address=/myhost.company/10.0.0.2
	```

1. Run the container

	```
	$ docker run \
		--name dnsmasq \
		-d \
		-p 53:53/udp \
		-p 5380:8080 \
		-v /opt/dnsmasq.conf:/etc/dnsmasq.conf \
		--log-opt "max-size=100m" \
		-e "USER=foo" \
		-e "PASS=bar" \
		jpillora/dnsmasq
	```

1. Visit `http://<docker-host>:5380`, authenticate with `foo/bar` and you should see

	<img width="726" alt="screen shot 2016-10-02 at 10 27 46 pm" src="https://cloud.githubusercontent.com/assets/633843/19020264/c6d8eee8-88ef-11e6-9eee-c09aa07cad62.png">

1. Test it out with

	```
	$ host myhost.company <docker-host>
	Using domain server:
	Name: <docker-host>
	Address: <docker-host>#53
	Aliases:

	myhost.company has address 10.0.0.2
	```

### Notes

* All logs go to stdout so you'll find them in `docker logs dnsmasq`

#### MIT License

Copyright &copy; 2016 Jaime Pillora &lt;dev@jpillora.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[dockerhub]: https://hub.docker.com/r/jpillora/dnsmasq/
