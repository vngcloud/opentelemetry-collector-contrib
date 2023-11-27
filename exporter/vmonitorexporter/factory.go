// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

//go:generate mdatagen metadata.yaml

package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"context"
	"fmt"
	"os"

	"go.opentelemetry.io/collector/component"
	"go.opentelemetry.io/collector/exporter"
	"go.opentelemetry.io/collector/exporter/exporterhelper"

	"github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter/internal/metadata"
	"github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter/proxy"
)

// NewFactory creates a factory for vMonitor exporter.
func NewFactory() exporter.Factory {
	return exporter.NewFactory(
		metadata.Type,
		createDefaultConfig,
		exporter.WithMetrics(createMetricsExporter, metadata.MetricsStability),
		exporter.WithLogs(createLogsExporter, metadata.MetricsStability),
	)
}

func createDefaultConfig() component.Config {
	hostname, _ := os.Hostname()
	return &Config{
		ClientID:          "",
		ClientSecret:      "",
		IamURL:            "https://iamapis.vngcloud.vn/accounts-api/v2/auth/token",
		Endpoint:          "https://monitoring-agent.vngcloud.vn:443",
		Hostname:          hostname,
		MetricBatchSize:   1000,
		MetricBufferLimit: 15000,
		ContentEncoding:   "",
		FlushInterval:     0,
		HTTPProxy: proxy.HTTPProxy{
			HTTPProxyURL:   "",
			UseSystemProxy: false,
		},
		// Socks5ProxyConfig: proxy.Socks5ProxyConfig{
		// 	Socks5ProxyAddress:  "",
		// 	Socks5ProxyEnabled:  false,
		// 	Socks5ProxyPassword: "",
		// 	Socks5ProxyUsername: "",
		// },
		// TCPProxy: proxy.TCPProxy{
		// 	UseProxy: false,
		// 	ProxyURL: "",
		// },

		Logs2Metrics: Logs2Metrics{
			DimensionKeys: []string{},
			ValueKeys:     []string{},
		},
	}
}

func createMetricsExporter(
	ctx context.Context,
	set exporter.CreateSettings,
	cfg component.Config,
) (exporter.Metrics, error) {
	cf := cfg.(*Config)

	metricsExporter, err := newMetricsExporter(cf)
	if err != nil {
		return nil, fmt.Errorf("cannot configure vmonitor metrics metricsExporter: %w", err)
	}

	return exporterhelper.NewMetricsExporter(
		ctx,
		set,
		cfg,
		metricsExporter.pushMetricsData,
		exporterhelper.WithShutdown(metricsExporter.Shutdown),
	)
}

func createLogsExporter(
	ctx context.Context,
	set exporter.CreateSettings,
	cfg component.Config,
) (exporter.Logs, error) {
	cf := cfg.(*Config)

	logsExporter, err := newLogsExporter(cf)
	if err != nil {
		return nil, fmt.Errorf("cannot configure vmonitor metrics metricsExporter: %w", err)
	}

	return exporterhelper.NewLogsExporter(
		ctx,
		set,
		cfg,
		logsExporter.pushLogsData,
		exporterhelper.WithShutdown(logsExporter.Shutdown),
	)
}
