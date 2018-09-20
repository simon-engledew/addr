package main // import "github.com/simon-engledew/ipaddr"

import (
	"fmt"
	"log"
	"net"

	kingpin "gopkg.in/alecthomas/kingpin.v2"
)

var (
	name    = kingpin.Arg("name", "Adaptor name").String()
	ipv4    = kingpin.Flag("4", "Show IPv4").Default("true").Bool()
	ipv6    = kingpin.Flag("6", "Show IPv6").Default("true").Bool()
	filters = kingpin.Flag("filter", "Address to filter").IPList()
)

func main() {
	kingpin.Version("0.0.1")
	kingpin.Parse()

	ifaces, err := net.Interfaces()
	if err != nil {
		log.Fatal(err)
	}

	var ipAddrs []net.IP

	for _, i := range ifaces {
		if *name == "" || i.Name == *name {
			addrs, _ := i.Addrs()

			for _, addr := range addrs {
				switch v := addr.(type) {
				case *net.IPNet:
					ipAddrs = append(ipAddrs, v.IP)
				case *net.IPAddr:
					ipAddrs = append(ipAddrs, v.IP)
				}
			}
		}
	}

OUTER:
	for _, ip := range ipAddrs {
		for _, filter := range *filters {
			if ip.Equal(filter) {
				continue OUTER
			}
		}

		is4 := ip.To4() != nil

		if *ipv4 && is4 {
			fmt.Println(ip)
		}
		if *ipv6 && !is4 {
			fmt.Println(ip)
		}
	}
}
