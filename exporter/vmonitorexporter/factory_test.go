// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package vmonitorexporter

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.opentelemetry.io/collector/component/componenttest"
	"go.opentelemetry.io/collector/exporter/exportertest"
)

func TestCreateDefaultConfig(t *testing.T) {
	factory := NewFactory()
	cfg := factory.CreateDefaultConfig()
	assert.NotNil(t, cfg, "failed to create default config")
	assert.NoError(t, componenttest.CheckConfigStruct(cfg))
}

func TestFactory_CreateLogsExporter(t *testing.T) {
	factory := NewFactory()
	cfg := withDefaultConfig(func(cfg *Config) {
		cfg.Endpoint = DefaultEndpoint
		cfg.ClientID = "aaaa"
		cfg.ClientSecret = "bbb"
	})
	params := exportertest.NewNopCreateSettings()
	exporter, err := factory.CreateLogsExporter(context.Background(), params, cfg)
	require.Error(t, err)
	require.Nil(t, exporter)

	// require.NoError(t, exporter.Shutdown(context.TODO()))
}
