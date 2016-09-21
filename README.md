
# docker-dnsmasq

dnsmasq in a docker container, configurable via a simple web UI

### Usage

1. Create a [`/opt/dnsmasq.conf`](http://oss.segetech.com/intra/srv/dnsmasq.conf) file on the Docker host

	``` ini
	#listen on container interface
	listen-address=0.0.0.0
	interface=eth0
	user=root
	log-queries

	#only use these namesservers
	no-resolv
	server=8.8.4.4
	server=8.8.8.8

	#static entries
	address=/myhost.company/10.0.0.2
	```

1. Run the container

	```
	$ docker run \
		--name dnsmasq \
		-d \
		-p 53:53/udp \
		-p 8080:8080 \
		-v /opt/dnsmasq.conf:/etc/dnsmasq.conf \
		-e "USER=foo" \
		-e "PASS=bar" \
		jpillora/dnsmasq
	```

1. Visit `http://<docker-host>:8080` and you should see

	![screen shot 2015-04-24 at 3 55 17 pm](https://cloud.githubusercontent.com/assets/633843/7313188/5b6646b4-ea9a-11e4-90fa-e804dcc34922.png)

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

Copyright &copy; 2015 Jaime Pillora &lt;dev@jpillora.com&gt;

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
