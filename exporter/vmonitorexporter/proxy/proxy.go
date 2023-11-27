// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package proxy // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter/proxy"

import (
	"fmt"
	"net/http"
	"net/url"

	"golang.org/x/net/proxy"
)

type HTTPProxy struct {
	UseSystemProxy bool   `mapstructure:"use_system_proxy"`
	HTTPProxyURL   string `mapstructure:"http_proxy_url"`
}

// type ProxyFunc func(req *http.Request) (*url.URL, error)

func (p *HTTPProxy) Proxy() (func(req *http.Request) (*url.URL, error), error) {
	if p.UseSystemProxy {
		return http.ProxyFromEnvironment, nil
	} else if len(p.HTTPProxyURL) > 0 {
		address, err := url.Parse(p.HTTPProxyURL)
		if err != nil {
			return nil, fmt.Errorf("error parsing proxy url %q: %w", p.HTTPProxyURL, err)
		}
		return http.ProxyURL(address), nil
	}

	return nil, nil
}

type TCPProxy struct {
	UseProxy bool   `mapstructure:"use_proxy"`
	ProxyURL string `mapstructure:"proxy_url"`
}

func (p *TCPProxy) Proxy() (*ProxiedDialer, error) {
	var dialer proxy.Dialer
	if p.UseProxy {
		if len(p.ProxyURL) > 0 {
			parsed, err := url.Parse(p.ProxyURL)
			if err != nil {
				return nil, fmt.Errorf("error parsing proxy url %q: %w", p.ProxyURL, err)
			}

			if dialer, err = proxy.FromURL(parsed, proxy.Direct); err != nil {
				return nil, err
			}
		} else {
			dialer = proxy.FromEnvironment()
		}
	} else {
		dialer = proxy.Direct
	}

	return &ProxiedDialer{dialer}, nil
}
