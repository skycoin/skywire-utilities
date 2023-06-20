// Package httputil pkg/httputil/dmsghttp.go
package httputil

// DMSGHTTPConf is struct of /dmsghttp endpoint of config bootstrap
type DMSGHTTPConf struct {
	DMSGServers        []dmsgServersConf `json:"dmsg_servers"`
	DMSGDiscovery      string            `json:"dmsg_discovery"`
	TranspordDiscovery string            `json:"transport_discovery"`
	AddressResolver    string            `json:"address_resolver"`
	RouteFinder        string            `json:"route_finder"`
	UptimeTracker      string            `json:"uptime_tracker"`
	ServiceDiscovery   string            `json:"service_discovery"`
}

type dmsgServersConf struct {
	Static string `json:"static"`
	Server struct {
		Address string `json:"address"`
	} `json:"server"`
}
