// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package basicstatsprocessor // import "github.com/open-telemetry/opentelemetry-collector-contrib/processor/basicstatsprocessor"

import (
	"context"
	"fmt"
	"math"
	"sort"
	"strings"
	"time"

	"github.com/sirupsen/logrus"
	"go.opentelemetry.io/collector/pdata/pmetric"
)

type BasicStats struct {
	cache        map[string]aggregate
	stats        []string
	dropOriginal bool
}

func newBasicStatsProcessor(cfg *Config) (*BasicStats, error) {
	if err := cfg.Validate(); err != nil {
		return nil, err
	}
	b := &BasicStats{
		cache:        make(map[string]aggregate),
		stats:        cfg.Stats,
		dropOriginal: cfg.DropOriginal,
	}
	return b, nil
}

type aggregate struct {
	fields map[string]basicstats
	name   string
}

type basicstats struct {
	count    float64
	min      float64
	max      float64
	sum      float64
	mean     float64
	diff     float64
	rate     float64
	interval time.Duration
	M2       float64   // intermediate value for variance/stdev
	LAST     float64   // intermediate value for diff
	TIME     time.Time // intermediate value for rate
}

func (bs *basicstats) PushValue(field string) (float64, bool) {
	switch field {
	case "count":
		return bs.count, true
	case "min":
		return bs.min, true
	case "max":
		return bs.max, true
	case "mean":
		return bs.mean, true
	case "sum":
		return bs.sum, true
	case "s2":
		if bs.count > 1 {
			return bs.M2 / (bs.count - 1), true
		}
		return 0, false
	case "stdev":
		if bs.count > 1 {
			return math.Sqrt(bs.M2 / (bs.count - 1)), true
		}
		return 0, false
	case "diff":
		return bs.diff, bs.count > 1
	case "rate":
		return bs.rate, bs.count > 1
	case "non_negative_diff":
		return bs.diff, bs.count > 1 && bs.diff >= 0
	case "non_negative_rate":
		return bs.rate, bs.count > 1 && bs.diff >= 0
	case "interval":
		return float64(bs.interval.Nanoseconds()), bs.count > 1
	default:
		return 0, false
	}
}

func (b *BasicStats) processMetrics(_ context.Context, md pmetric.Metrics) (pmetric.Metrics, error) {
	b.AddMetric(md)

	result := pmetric.NewMetrics()
	rmResult := result.ResourceMetrics()

	for _, stat := range b.stats {
		newMetrics := b.Push(stat, md)
		rms := newMetrics.ResourceMetrics()
		rms.MoveAndAppendTo(rmResult)
	}

	if !b.dropOriginal {
		rms := md.ResourceMetrics()
		rms.MoveAndAppendTo(rmResult)
	}
	return result, nil
}

func (b *BasicStats) AddMetric(md pmetric.Metrics) {
	rms := md.ResourceMetrics()
	for i := 0; i < rms.Len(); i++ {
		rm := rms.At(i)
		sms := rm.ScopeMetrics()
		for i := 0; i < sms.Len(); i++ {
			sm := sms.At(i)
			ms := sm.Metrics()
			for j := 0; j < ms.Len(); j++ {
				m := ms.At(j)

				// logrus.Infof("--- addMetric: %+v %+v", m.Name(), m.Type())
				switch m.Type() {
				case pmetric.MetricTypeGauge:
					b.accumulateGauge(m)
				case pmetric.MetricTypeSum:
					b.accumulateSum(m)
				// case pmetric.MetricTypeHistogram:
				// 	return b.accumulateDoubleHistogram(metric)
				// case pmetric.MetricTypeSummary:
				// 	return b.accumulateSummary(metric)
				default:
					fmt.Println("failed to Add Metric")
				}
			}
		}
	}
}

func (b *BasicStats) accumulateGauge(metric pmetric.Metric) {
	dps := metric.Gauge().DataPoints()
	for i := 0; i < dps.Len(); i++ {
		ip := dps.At(i)
		key := mapToString(ip.Attributes().AsRaw())

		switch ip.ValueType() {
		case pmetric.NumberDataPointValueTypeDouble:
			b.AddToCache(metric.Name(), key, ip.DoubleValue(), ip.Timestamp().AsTime())
		case pmetric.NumberDataPointValueTypeInt:
			b.AddToCache(metric.Name(), key, float64(ip.IntValue()), ip.Timestamp().AsTime())
		}
	}
}
func (b *BasicStats) accumulateSum(metric pmetric.Metric) {
	dps := metric.Sum().DataPoints()
	for i := 0; i < dps.Len(); i++ {
		ip := dps.At(i)
		key := mapToString(ip.Attributes().AsRaw())

		switch ip.ValueType() {
		case pmetric.NumberDataPointValueTypeDouble:
			b.AddToCache(metric.Name(), key, ip.DoubleValue(), ip.Timestamp().AsTime())
		case pmetric.NumberDataPointValueTypeInt:
			b.AddToCache(metric.Name(), key, float64(ip.IntValue()), ip.Timestamp().AsTime())
		}
	}
}
func (b *BasicStats) AddToCache(name, key string, value interface{}, t time.Time) {
	id := name
	if _, ok := b.cache[id]; !ok {
		// hit an uncached metric, create caches for first time:
		a := aggregate{
			name:   name,
			fields: make(map[string]basicstats),
		}
		if fv, ok := convert(value); ok {
			a.fields[key] = basicstats{
				count: 1,
				min:   fv,
				max:   fv,
				mean:  fv,
				sum:   fv,
				diff:  0.0,
				rate:  0.0,
				M2:    0.0,
				LAST:  fv,
				TIME:  t,
			}
		}

		b.cache[id] = a
	} else {
		if fv, ok := convert(value); ok {
			if _, ok := b.cache[id].fields[key]; !ok {
				// hit an uncached field of a cached metric
				b.cache[id].fields[key] = basicstats{
					count:    1,
					min:      fv,
					max:      fv,
					mean:     fv,
					sum:      fv,
					diff:     0.0,
					rate:     0.0,
					interval: 0,
					M2:       0.0,
					LAST:     fv,
					TIME:     t,
				}
				return
			}

			tmp := b.cache[id].fields[key]
			// https://en.m.wikipedia.org/wiki/Algorithms_for_calculating_variance
			// variable initialization
			x := fv
			mean := tmp.mean
			m2 := tmp.M2
			// counter compute
			n := tmp.count + 1
			tmp.count = n
			// mean compute
			delta := x - mean
			mean += delta / n // mean = mean + delta/n
			tmp.mean = mean
			// variance/stdev compute
			// m2 = m2 + delta*(x-mean)
			m2 += delta * (x - mean)
			tmp.M2 = m2
			// max/min compute
			if fv < tmp.min {
				tmp.min = fv
			} else if fv > tmp.max {
				tmp.max = fv
			}
			// sum compute
			tmp.sum += fv
			// diff compute
			tmp.diff = fv - tmp.LAST
			// interval compute
			tmp.interval = t.Sub(tmp.TIME)
			// rate compute
			if !t.Equal(tmp.TIME) {
				tmp.rate = tmp.diff / tmp.interval.Seconds()
			}
			tmp.TIME = t
			tmp.LAST = fv
			// store final data
			b.cache[id].fields[key] = tmp
		}
	}
}

func (b *BasicStats) Push(stats string, md pmetric.Metrics) pmetric.Metrics {
	_rms := md.ResourceMetrics()
	metrics := pmetric.NewMetrics()
	rms := metrics.ResourceMetrics()
	_rms.CopyTo(rms)
	for i := 0; i < rms.Len(); i++ {
		rm := rms.At(i)
		sms := rm.ScopeMetrics()
		for i := 0; i < sms.Len(); i++ {
			sm := sms.At(i)
			ms := sm.Metrics()
			for j := 0; j < ms.Len(); j++ {
				m := ms.At(j)
				switch m.Type() {
				case pmetric.MetricTypeGauge:
					b.PushGaugeMetric(stats, m)
				case pmetric.MetricTypeSum:
					b.PushSumMetric(stats, m)
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
				m.SetName(m.Name() + "_" + stats)
			}
		}
	}
	return metrics
}

func (b *BasicStats) PushSumMetric(stats string, m pmetric.Metric) {
	dps := m.Sum().DataPoints()
	for i := 0; i < dps.Len(); i++ {
		ip := dps.At(i)
		key := mapToString(ip.Attributes().AsRaw())
		// assign new value
		id := m.Name()
		if agg, ok := b.cache[id]; ok {
			if statsCache, ook := agg.fields[key]; ook {
				if value, oook := statsCache.PushValue(stats); oook {
					ip.SetDoubleValue(value)
				} else {
					// logrus.Infof("DROP THIS POINT Double Value %+v, %+v, %+v", stats, id, key)
					dps.RemoveIf(func(_dp pmetric.NumberDataPoint) bool {
						return _dp == ip
					})
					i--
				}
			} else {
				logrus.Infof("ERROR wrote but can't get %+v", key)
			}
		} else {
			logrus.Infof("ERROR wrote but can't get")
		}
	}
}

func (b *BasicStats) PushGaugeMetric(stats string, m pmetric.Metric) {
	dps := m.Gauge().DataPoints()
	for i := 0; i < dps.Len(); i++ {
		ip := dps.At(i)
		key := mapToString(ip.Attributes().AsRaw())
		// assign new value
		id := m.Name()
		if agg, ok := b.cache[id]; ok {
			if statsCache, ook := agg.fields[key]; ook {
				if value, oook := statsCache.PushValue(stats); oook {
					ip.SetDoubleValue(value)
				} else {
					// logrus.Infof("DROP THIS POINT Double Value %+v, %+v, %+v", stats, id, key)
					dps.RemoveIf(func(_dp pmetric.NumberDataPoint) bool {
						return _dp == ip
					})
					i--
				}
			} else {
				logrus.Infof("ERROR wrote but can't get %+v", key)
			}
		} else {
			logrus.Infof("ERROR wrote but can't get")
		}
	}
}

func (b *BasicStats) Reset() {
	b.cache = make(map[string]aggregate)
}

func convert(in interface{}) (float64, bool) {
	switch v := in.(type) {
	case float64:
		return v, true
	case int64:
		return float64(v), true
	case uint64:
		return float64(v), true
	default:
		return 0, false
	}
}

func mapToString(data map[string]interface{}) string {
	keys := make([]string, 0, len(data))
	for k := range data {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	var parts []string
	for _, key := range keys {
		value := data[key]
		// for key, value := range data {
		// Convert the key and value to strings and concatenate them with ":"
		part := fmt.Sprintf("%s:%v", key, value)
		parts = append(parts, part)
	}
	// Join the parts with "&" to form the final string
	return strings.Join(parts, "&")
}
