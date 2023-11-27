// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package sqlqueryreceiver // import "github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sqlqueryreceiver"

import (
	"errors"
	"time"

	"go.opentelemetry.io/collector/component"
	"go.opentelemetry.io/collector/receiver/scraperhelper"
	"go.uber.org/multierr"

	"github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sqlqueryreceiver/internal/metadata"
)

type Config struct {
	scraperhelper.ScraperControllerSettings `mapstructure:",squash"`
	Driver                                  string        `mapstructure:"driver"`
	DataSource                              string        `mapstructure:"datasource"`
	Queries                                 []Query       `mapstructure:"queries"`
	StorageID                               *component.ID `mapstructure:"storage"`
}

func (c Config) Validate() error {
	if c.Driver == "" {
		return errors.New("'driver' cannot be empty")
	}
	if c.DataSource == "" {
		return errors.New("'datasource' cannot be empty")
	}
	if len(c.Queries) == 0 {
		return errors.New("'queries' cannot be empty")
	}
	for _, query := range c.Queries {
		if err := query.Validate(); err != nil {
			return err
		}
	}
	return nil
}

type Query struct {
	SQL  string    `mapstructure:"sql"`
	Logs []LogsCfg `mapstructure:"logs"`
}

func (q Query) Validate() error {
	var errs error
	if q.SQL == "" {
		errs = multierr.Append(errs, errors.New("'query.sql' cannot be empty"))
	}
	if len(q.Logs) == 0 {
		errs = multierr.Append(errs, errors.New("at least one of 'query.logs' must not be empty"))
	}
	for _, logs := range q.Logs {
		if err := logs.Validate(); err != nil {
			errs = multierr.Append(errs, err)
		}
	}
	return errs
}

type LogsCfg struct {
	BodyColumn string `mapstructure:"body_column"`
}

func (config LogsCfg) Validate() error {
	var errs error
	if config.BodyColumn == "" {
		errs = multierr.Append(errs, errors.New("'body_column' must not be empty"))
	}
	return errs
}

func createDefaultConfig() component.Config {
	cfg := scraperhelper.NewDefaultScraperControllerSettings(metadata.Type)
	cfg.CollectionInterval = 10 * time.Second
	return &Config{
		ScraperControllerSettings: cfg,
	}
}
