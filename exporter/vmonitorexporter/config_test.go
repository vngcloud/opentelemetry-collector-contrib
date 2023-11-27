// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Package vmonitorexporter contains an opentelemetry-collector exporter
// for Elasticsearch.
package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func Test_ValidConfig(t *testing.T) {
	cfg := Config{
		Logs2Metrics: Logs2Metrics{
			DimensionKeys: make([]string, 0),
			ValueKeys:     make([]string, 0),
		},
		// HTTPProxy:         "",
		Hostname:          "",
		ContentEncoding:   "",
		MetricBufferLimit: 100,
		MetricBatchSize:   100,
		ClientSecret:      "",
		ClientID:          "",
		Endpoint:          "",
		IamURL:            "",
		FlushInterval:     5,
	}
	err := cfg.Validate()
	require.Error(t, err)
}
