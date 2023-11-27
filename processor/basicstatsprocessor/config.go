// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package basicstatsprocessor // import "github.com/open-telemetry/opentelemetry-collector-contrib/processor/basicstatsprocessor"
import (
	"fmt"

	"github.com/sirupsen/logrus"
	"go.opentelemetry.io/collector/component"
	"golang.org/x/exp/slices"
)

type Config struct {
	DropOriginal bool     `mapstructure:"drop_original"`
	Stats        []string `mapstructure:"stats"`
}

var _ component.Config = (*Config)(nil)

func (cfg *Config) Validate() error {
	var newValid []string
	valid := []string{"count", "diff", "rate", "min", "max", "mean", "non_negative_diff", "non_negative_rate", "stdev", "s2", "sum", "interval"}
	for _, v := range cfg.Stats {
		if slices.Contains(valid, v) {
			newValid = append(newValid, v)
		} else {
			logrus.Errorf("Invalid stats, ignore: %+v\n", v)
		}
	}
	if len(newValid) < 1 {
		return fmt.Errorf("no stats config")
	}
	cfg.Stats = newValid
	return nil
}
