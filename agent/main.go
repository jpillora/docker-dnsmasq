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
)

var config []byte

func main() {
	//restore initial config
	initConfig, err := ioutil.ReadFile("dnsmasq.conf")
	if err == nil && len(initConfig) > 0 {
		err = load(initConfig)
		if err != nil {
			log.Printf("failed to load initial config, using default (%s)", err)
		}
	}
	//serve
	http.HandleFunc("/configure", configure)
	http.Handle("/", http.FileServer(http.Dir("static")))
	log.Println("Running dnsmasq agent on 8080")
	http.ListenAndServe(":8080", nil)
}

func configure(w http.ResponseWriter, r *http.Request) {

	if r.Method != "POST" {
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

func load(newConfig []byte) error {
	if len(newConfig) == 0 {
		return fmt.Errorf("no config")
	}

	oldConfig, err := ioutil.ReadFile("/etc/dnsmasq.conf")
	if err != nil {
		return fmt.Errorf("old config read failed: %s", err)
	}

	if bytes.Compare(oldConfig, newConfig) == 0 {
		return fmt.Errorf("no change")
	}

	if err := ioutil.WriteFile("/etc/dnsmasq.conf", newConfig, 600); err != nil {
		return fmt.Errorf("new test config write failed: %s", err)
	}

	if out, err := exec.Command("dnsmasq", "--test").CombinedOutput(); err != nil {
		//validation failed, restore old config
		err := ioutil.WriteFile("/etc/dnsmasq.conf", oldConfig, 600)
		if err != nil {
			return fmt.Errorf("prev config write failed: %s", err)
		}
		log.Printf("validation error")
		return parseError(out, err)
	}

	//config validated, reload dnsmasq
	if out, err := exec.Command("sudo", "service", "dnsmasq", "restart").CombinedOutput(); err != nil {
		log.Printf("reload failed")
		return parseError(out, err)
	}

	log.Printf("loaded config")
	config = newConfig
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
