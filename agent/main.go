package main

import (
	"bytes"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os/exec"
	"regexp"
	"sync"
)

var config []byte

func main() {
	//tag logs
	log.SetPrefix("[agentd] ")
	//restore initial config
	config, _ = ioutil.ReadFile("/etc/dnsmasq.conf")
	exec.Command("service", "dnsmasq", "restart").Run()
	//serve
	http.HandleFunc("/configure", configure)
	http.Handle("/", http.FileServer(http.Dir("static")))
	log.Println("Running dnsmasq agent on 8080")
	http.ListenAndServe(":8080", nil)
}

var rootuser = regexp.MustCompile(`(^|\n)user=root\n`)

func configure(w http.ResponseWriter, r *http.Request) {

	if r.Method != "POST" {
		log.Println("get config")
		w.Write(config)
		return
	}

	newConfig, _ := ioutil.ReadAll(r.Body)
	defer r.Body.Close()

	err := load(newConfig)
	if err != nil {
		w.WriteHeader(400)
		w.Write([]byte(err.Error()))
		return
	}

	w.WriteHeader(200)
}

var loadlock sync.Mutex

func load(newConfig []byte) error {

	//only load one at a time
	loadlock.Lock()
	defer loadlock.Unlock()

	if len(newConfig) == 0 {
		return fmt.Errorf("No config")
	}

	if !rootuser.Match(newConfig) {
		return fmt.Errorf("Config must have 'user=root' enabled")
	}

	oldConfig, err := ioutil.ReadFile("/etc/dnsmasq.conf")
	if err != nil {
		return fmt.Errorf("Old config read failed: %s", err)
	}

	if bytes.Compare(oldConfig, newConfig) == 0 {
		return fmt.Errorf("No change")
	}

	if err := ioutil.WriteFile("/etc/dnsmasq.conf", newConfig, 600); err != nil {
		return fmt.Errorf("New config temp write failed: %s", err)
	}

	if out, err := exec.Command("dnsmasq", "--test").CombinedOutput(); err != nil {
		//validation failed, restore old config
		err := ioutil.WriteFile("/etc/dnsmasq.conf", oldConfig, 600)
		if err != nil {
			return fmt.Errorf("Last config write failed: %s", err)
		}
		log.Printf("validation error")
		return parseError(out, err)
	}

	//config validated, reload dnsmasq
	log.Println("restarting...")
	if out, err := exec.Command("service", "dnsmasq", "restart").CombinedOutput(); err != nil {
		log.Printf("reload failed: %s", out)
		return parseError(out, err)
	}

	log.Printf("set config")

	config = make([]byte, len(newConfig))
	copy(config, newConfig)
	return nil
}

var re = regexp.MustCompile(`dnsmasq: (.+)`)

func parseError(out []byte, err error) error {
	m := re.FindStringSubmatch(string(out))
	if len(m) > 0 {
		return errors.New(m[1])
	}
	return err
}
