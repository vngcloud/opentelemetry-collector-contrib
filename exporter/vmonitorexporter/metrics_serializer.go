// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Package vmonitorexporter contains an opentelemetry-collector exporter
// for Elasticsearch.
package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"fmt"
	"time"

	"go.opentelemetry.io/collector/pdata/pmetric"
)

type Serializer struct {
	Hostname string
}

func NewSerializer(hostname string) Serializer {
	s := Serializer{
		Hostname: hostname,
	}
	return s
}

func (s *Serializer) Serialize(metric pmetric.Metrics) []Metric {
	m := s.createObject(metric)
	// for _, metric := range m {
	// 	metric.Sanitize()
	// 	// klog.Infof("---: %+v\n", metric)
	// }
	return m
}

func (s *Serializer) createObject(md pmetric.Metrics) []Metric {
	fmt.Println("---------- createObject")
	var metricss []Metric

	metrics := md.ResourceMetrics()
	for i := 0; i < metrics.Len(); i++ {
		// n += pe.collector.processMetrics(metrics.At(i))
		rm := metrics.At(i)
		// fmt.Println("---", rm)
		// now := time.Now()
		ilms := rm.ScopeMetrics()
		// resourceAttrs := rm.Resource().Attributes()

		for i := 0; i < ilms.Len(); i++ {
			ilm := ilms.At(i)

			metrics := ilm.Metrics()
			for j := 0; j < metrics.Len(); j++ {
				// m := metrics.At(j)
				// klog.Infof("accumulating metric: %+v\n", m.Name())
				obj, _ := s.addMetric(metrics.At(j)) // .................
				if obj != nil {
					metricss = append(metricss, obj...)
				}
			}
		}
	}

	return metricss
}

func (s *Serializer) addMetric(metric pmetric.Metric) ([]Metric, error) {
	if metric.Name() == "" {
		// a.logger.Error("metric name is empty")
		fmt.Println("metric name is empty")
		return nil, fmt.Errorf("metric name is empty")
	}
	// klog.Infof("--- addMetric: %+v %+v", metric.Name(), metric.Type())
	metricNamePrefix, _ := SanitizeMetricName(metric.Name())
	metric.SetName(metricNamePrefix)
	switch metric.Type() {
	case pmetric.MetricTypeGauge:
		return s.accumulateGauge(metric), nil
	case pmetric.MetricTypeSum:
		return s.accumulateSum(metric), nil
	// case pmetric.MetricTypeHistogram:
	// 	return s.accumulateDoubleHistogram(metric)
	// case pmetric.MetricTypeSummary:
	// 	return s.accumulateSummary(metric)
	default:
		// a.logger.With(
		// 	zap.String("data_type", string(metric.Type())),
		// 	zap.String("metric_name", metric.Name()),
		// ).Error("failed to translate metric")
		fmt.Println("failed to serialize metric")
	}

	return nil, nil
}

func (s *Serializer) accumulateGauge(metric pmetric.Metric) []Metric {
	var metrics []Metric
	dps := metric.Gauge().DataPoints()

	for i := 0; i < dps.Len(); i++ {
		ip := dps.At(i)
		m := NewMetric()
		for k, v := range ip.Attributes().AsRaw() {
			name, _ := SanitizeDimensionName(k)
			// valueTag, ok := SanitizeLabelValue(tag.Value)
			valueTag, _ := SanitizeDimensionValue(fmt.Sprintf("%v", v))

			m.Dimensions[name] = valueTag
		}
		m.Dimensions["host"] = s.Hostname
		m.Name = metric.Name()
		m.Timestamp = float64(ip.Timestamp().AsTime().UnixNano() / int64(time.Millisecond))
		m.ValueMeta = ValueMeta{}
		switch ip.ValueType() {
		case pmetric.NumberDataPointValueTypeDouble:
			m.Value = ip.DoubleValue()
		case pmetric.NumberDataPointValueTypeInt:
			m.Value = float64(ip.IntValue())
		}

		metrics = append(metrics, m)
	}
	return metrics
}

func (s *Serializer) accumulateSum(metric pmetric.Metric) []Metric {
	var metrics []Metric
	dps := metric.Sum().DataPoints()

	for i := 0; i < dps.Len(); i++ {
		ip := dps.At(i)
		m := NewMetric()
		for k, v := range ip.Attributes().AsRaw() {
			name, _ := SanitizeDimensionName(k)
			// valueTag, ok := SanitizeLabelValue(tag.Value)
			valueTag, _ := SanitizeDimensionValue(fmt.Sprintf("%v", v))

			m.Dimensions[name] = valueTag
		}
		m.Dimensions["host"] = s.Hostname
		m.Name = metric.Name()
		m.Timestamp = float64(ip.Timestamp().AsTime().UnixNano() / int64(time.Millisecond))
		m.ValueMeta = ValueMeta{}
		switch ip.ValueType() {
		case pmetric.NumberDataPointValueTypeDouble:
			m.Value = ip.DoubleValue()
		case pmetric.NumberDataPointValueTypeInt:
			m.Value = float64(ip.IntValue())
		}

		metrics = append(metrics, m)
	}
	return metrics
}

// func (s *Serializer) accumulateDoubleHistogram(metric pmetric.Metric) ([]Metric, error) {
// 	var metrics []Metric
// 	dps := metric.Histogram().DataPoints()

// 	for i := 0; i < dps.Len(); i++ {
// 		ip := dps.At(i)
// 		m := NewMetric()
// 		for k, v := range ip.Attributes().AsRaw() {
// 			name, ok := SanitizeLabelName(k)
// 			if !ok || k == "" {
// 				continue
// 			}
// 			// valueTag, ok := SanitizeLabelValue(tag.Value)
// 			valueTag, ok := SanitizeWhitelistLabelValue(fmt.Sprintf("%v", v))
// 			if !ok {
// 				continue
// 			}

// 			m.Dimensions[name] = valueTag
// 		}
// 		m.Dimensions["host"] = s.Hostname
// 		m.Name = metric.Name()
// 		m.Timestamp = float64(ip.Timestamp().AsTime().UnixNano() / int64(time.Millisecond))
// 		m.ValueMeta = ValueMeta{}
// 		m.Value = ip.Sum()
// 		metrics = append(metrics, m)
// 	}
// 	return metrics, nil
// }

// func (s *Serializer) accumulateSummary(metric pmetric.Metric) []Metric {
// 	var metrics []Metric
// 	dps := metric.Summary().DataPoints()

// 	for i := 0; i < dps.Len(); i++ {
// 		ip := dps.At(i)
// 		m := NewMetric()
// 		for k, v := range ip.Attributes().AsRaw() {
// 			name, ok := SanitizeLabelName(k)
// 			if !ok || k == "" {
// 				continue
// 			}
// 			// valueTag, ok := SanitizeLabelValue(tag.Value)
// 			valueTag, ok := SanitizeWhitelistLabelValue(fmt.Sprintf("%v", v))
// 			if !ok {
// 				continue
// 			}

// 			m.Dimensions[name] = valueTag
// 		}
// 		m.Dimensions["host"] = s.Hostname
// 		m.Name = metric.Name()
// 		m.Timestamp = float64(ip.Timestamp().AsTime().UnixNano() / int64(time.Millisecond))
// 		m.ValueMeta = ValueMeta{}
// 		m.Value = ip.Sum()

// 		metrics = append(metrics, m)
// 	}
// 	return metrics
// }
