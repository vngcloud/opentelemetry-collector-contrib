// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package proxy // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter/proxy"

import (
	"golang.org/x/net/proxy"
)

type Socks5ProxyConfig struct {
	Socks5ProxyEnabled  bool   `mapstructure:"socks5_enabled"`
	Socks5ProxyAddress  string `mapstructure:"socks5_address"`
	Socks5ProxyUsername string `mapstructure:"socks5_username"`
	Socks5ProxyPassword string `mapstructure:"socks5_password"`
}

func (c *Socks5ProxyConfig) GetDialer() (proxy.Dialer, error) {
	var auth *proxy.Auth
	if c.Socks5ProxyPassword != "" || c.Socks5ProxyUsername != "" {
		auth = new(proxy.Auth)
		auth.User = c.Socks5ProxyUsername
		auth.Password = c.Socks5ProxyPassword
	}
	return proxy.SOCKS5("tcp", c.Socks5ProxyAddress, auth, proxy.Direct)
}
