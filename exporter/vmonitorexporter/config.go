// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Package vmonitorexporter contains an opentelemetry-collector exporter
// for Elasticsearch.
package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"fmt"

	"github.com/sirupsen/logrus"
	"go.opentelemetry.io/collector/component"

	"github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter/proxy"
)

// Config defines configuration for Elastic exporter.
type Config struct {
	Endpoint          string `mapstructure:"endpoint"`
	ClientID          string `mapstructure:"client_id"`
	ClientSecret      string `mapstructure:"client_secret"`
	IamURL            string `mapstructure:"iam_url"`
	Hostname          string `mapstructure:"hostname"`
	ContentEncoding   string `mapstructure:"content_encoding"`
	MetricBatchSize   int    `mapstructure:"metric_batch_size"`
	MetricBufferLimit int    `mapstructure:"metric_buffer_limit"`
	FlushInterval     int    `mapstructure:"flush_interval"`

	Logs2Metrics    Logs2Metrics `mapstructure:"logs_to_metrics"`
	proxy.HTTPProxy `mapstructure:",squash"`
	// proxy.Socks5ProxyConfig
	// proxy.TCPProxy
}

type Logs2Metrics struct {
	DimensionKeys []string `mapstructure:"dimension_keys"`
	ValueKeys     []string `mapstructure:"value_keys"`
}

var _ component.Config = (*Config)(nil)

const (
	DefaultEndpoint = "https://monitoring-agent.vngcloud.vn:443"
	DefaultIAMURL   = "https://iamapis.vngcloud.vn/accounts-api/v2/auth/token"
)

// Validate validates the elasticsearch server configuration.
func (cfg *Config) Validate() error {
	if cfg.ClientID == "" || cfg.ClientSecret == "" {
		return fmt.Errorf("invalid client_id and client_secret in config")
	}

	if cfg.Endpoint == "" {
		logrus.Warnln("Invalid endpoint, set to default: ", DefaultEndpoint)
		cfg.Endpoint = DefaultEndpoint
	}
	if cfg.IamURL == "" {
		logrus.Warnln("Invalid iam_url, set to default: ", DefaultIAMURL)
		cfg.IamURL = DefaultIAMURL
	}

	for i := range cfg.Logs2Metrics.DimensionKeys {
		cfg.Logs2Metrics.DimensionKeys[i], _ = SanitizeDimensionName(cfg.Logs2Metrics.DimensionKeys[i])
	}
	return nil
}

func withDefaultConfig(fns ...func(*Config)) *Config {
	cfg := createDefaultConfig().(*Config)
	for _, fn := range fns {
		fn(cfg)
	}
	return cfg
}
