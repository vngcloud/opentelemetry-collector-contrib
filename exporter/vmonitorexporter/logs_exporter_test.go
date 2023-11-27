// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Package vmonitorexporter contains an opentelemetry-collector exporter
// for Elasticsearch.
package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"testing"

	"github.com/stretchr/testify/require"
)

// test anyToFloat64
func Test_anyToFloat64(t *testing.T) {
	tests := []struct {
		name  string
		value interface{}
		want  float64
	}{
		{"int", 1, 1},
		{"int32", int32(2), 2},
		{"int64", int64(3), 3},
		{"float32", float32(4.5), 4.5},
		{"float64", float64(5), 5},
		{"bool", true, 1},
		{"string", "622222222222222222", 622222222222222222},
		{"string", "6222222.22222222222", 6222222.22222222222},
		{"string", "-622.2222", -622.2222},
		{"string", "+622.2222", 622.2222},
		{"default", nil, -1},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, _ := anyToFloat64(tt.value)
			require.Equal(t, tt.want, got)
		})
	}
}

// func newTestExporter(t *testing.T, url string, fns ...func(*Config)) *vmonitorLogsExporter {
// 	exporter, err := newLogsExporter(withTestExporterConfig(fns...)(url))
// 	require.NoError(t, err)

// 	t.Cleanup(func() {
// 		require.NoError(t, exporter.Shutdown(context.TODO()))
// 	})
// 	return exporter
// }

// func withTestExporterConfig(fns ...func(*Config)) func(string) *Config {
// 	return func(url string) *Config {
// 		var configMods []func(*Config)
// 		configMods = append(configMods, func(cfg *Config) {
// 			cfg.Endpoint = url
// 			//cfg.NumWorkers = 1
// 			//cfg.Flush.Interval = 10 * time.Millisecond
// 		})
// 		configMods = append(configMods, fns...)
// 		return withDefaultConfig(configMods...)
// 	}
// }

// func mustSend(t *testing.T, exporter *vmonitorLogsExporter, contents string) {
// 	err := pushDocuments(context.TODO(), zap.L(), exporter.index, []byte(contents), exporter.bulkIndexer, exporter.maxAttempts)
// 	require.NoError(t, err)
// }
