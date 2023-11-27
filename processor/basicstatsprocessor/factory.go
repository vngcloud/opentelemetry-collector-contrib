// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package basicstatsprocessor // import "github.com/open-telemetry/opentelemetry-collector-contrib/processor/basicstatsprocessor"

import (
	"context"
	"fmt"

	"go.opentelemetry.io/collector/component"
	"go.opentelemetry.io/collector/consumer"
	"go.opentelemetry.io/collector/processor"
	"go.opentelemetry.io/collector/processor/processorhelper"

	"github.com/open-telemetry/opentelemetry-collector-contrib/processor/basicstatsprocessor/internal/metadata"
)

var consumerCapabilities = consumer.Capabilities{MutatesData: true}

// NewFactory returns a new factory for the Metrics transform processor.
func NewFactory() processor.Factory {
	return processor.NewFactory(
		metadata.Type,
		createDefaultConfig,
		processor.WithMetrics(createMetricsProcessor, metadata.MetricsStability))
}

func createDefaultConfig() component.Config {
	return &Config{
		DropOriginal: false,
		Stats:        []string{},
	}
}

func createMetricsProcessor(
	ctx context.Context,
	set processor.CreateSettings,
	cfg component.Config,
	nextConsumer consumer.Metrics,
) (processor.Metrics, error) {
	cf := cfg.(*Config)

	metricsProcessor, err := newBasicStatsProcessor(cf)
	if err != nil {
		return nil, fmt.Errorf("cannot configure basicStatProcessor: %w", err)
	}

	return processorhelper.NewMetricsProcessor(
		ctx,
		set,
		cfg,
		nextConsumer,
		metricsProcessor.processMetrics,
		processorhelper.WithCapabilities(consumerCapabilities))
}
