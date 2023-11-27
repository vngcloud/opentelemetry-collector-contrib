// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Package vmonitorexporter contains an opentelemetry-collector exporter
// for Elasticsearch.
package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"fmt"
	"regexp"
	"strings"

	"github.com/sirupsen/logrus"
)

var (
	IsDimensionName = regexp.MustCompile(`^[a-z_A-Z][a-z_A-Z0-9\-.]*$`)
	IsMetricName    = regexp.MustCompile(`^[a-z_A-Z][a-z_A-Z0-9\-./]*$`)
	IsWhiteListChar = regexp.MustCompile(`^[a-z_A-Z0-9\-./]*$`)

	// greedy is expect to remove ? at the end
	IsBlackListChar     = regexp.MustCompile(`[^a-z_A-Z0-9\-./]+`)
	IsDimensionBackList = regexp.MustCompile(`^["&;<=>\\{|}]*$`)
)

type Metric struct {
	Name       string     `json:"name" validate:"required,special_char"`
	Dimensions Dimensions `json:"dimensions" validate:"required,dms"`
	Value      float64    `json:"value" validate:"required" binding:"numeric"`
	Timestamp  float64    `json:"timestamp" validate:"required,numeric,timestamp"`
	ValueMeta  ValueMeta  `json:"value_meta" validate:"vm"`
}

type ValueMeta map[string]interface{}
type Dimensions map[string]interface{}

func NewMetric() Metric {
	return Metric{
		Dimensions: Dimensions{},
		ValueMeta:  ValueMeta{},
	}
}
func (m *Metric) Sanitize() {
	// tags
	if str, ok := valid(m.Name, IsMetricName); ok {
		m.Name = str
	} else {
		logrus.Errorln("invalid metric name")
		// ..................
	}

	for key, element := range m.Dimensions {
		// fmt.Println("Key:", key, "=>", "Element:", element)
		if str, ok := valid(key, IsDimensionName); ok {
			delete(m.Dimensions, key)
			m.Dimensions[str] = validDimensionValue(fmt.Sprintf("%v", element))
		} else {
			logrus.Errorln("invalid dimension")
			// ....................
			delete(m.Dimensions, key)
			continue
		}
	}
}

func valid(str string, f *regexp.Regexp) (string, bool) {
	if len(str) < MinCharMetricName {
		return str, false
	}
	if len(str) > MaxCharMetricName {
		str = str[:MaxCharMetricName]
	}
	if f.MatchString(str) {
		return str, true
	}
	if !f.MatchString(str[:1]) {
		str = strings.Replace(str, str[:1], "_", 1)
	}
	return IsBlackListChar.ReplaceAllString(str, "_"), true
}

func validDimensionValue(str string) string {
	if len(str) > MaxCharMetricName {
		str = str[:MaxCharMetricName]
	}
	return IsBlackListChar.ReplaceAllString(str, "_")
}
