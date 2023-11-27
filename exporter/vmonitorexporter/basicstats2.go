// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"fmt"
	"sort"
	"strings"
)

type BasicStats2 struct {
	cache        map[string]aggregate2
	stats        []string
	dropOriginal bool
}

func NewBasicStats2Processor() BasicStats2 {
	b := BasicStats2{
		cache: make(map[string]aggregate2),
		// stats:        cfg.Stats,
		// dropOriginal: cfg.DropOriginal,
		stats:        []string{"diff"},
		dropOriginal: true,
	}
	return b
}

type aggregate2 struct {
	fields map[string]basicstats2
	name   string
}

type basicstats2 struct {
	count float64
	// min      float64
	// max      float64
	// sum      float64
	// mean     float64
	diff float64
	// rate     float64
	// interval time.Duration
	// M2       float64   // intermediate value for variance/stdev
	LAST float64 // intermediate value for diff
	// TIME     time.Time // intermediate value for rate
}

func (b *BasicStats2) ProcessValue(name, key, field string, value float64) (float64, bool) {
	id := name
	if _, ok := b.cache[id]; !ok {
		// hit an uncached metric, create caches for first time:
		a := aggregate2{
			name:   name,
			fields: make(map[string]basicstats2),
		}
		if fv, ok := convert2(value); ok {
			a.fields[key] = basicstats2{
				count: 1,
				// min:   fv,
				// max:   fv,
				// mean:  fv,
				// sum:   fv,
				diff: 0.0,
				// rate:  0.0,
				// M2:    0.0,
				LAST: fv,
				// TIME:  t,
			}
		}
		b.cache[id] = a
		b2 := b.cache[id].fields[key]
		return b2.PushValue(field)
	}

	fv, ok := convert2(value)
	if !ok {
		return -1, false
	}

	if _, ok := b.cache[id].fields[key]; !ok {
		// hit an uncached field of a cached metric
		b.cache[id].fields[key] = basicstats2{
			count: 1,
			// min:      fv,
			// max:      fv,
			// mean:     fv,
			// sum:      fv,
			diff: 0.0,
			// rate:     0.0,
			// interval: 0,
			// M2:       0.0,
			LAST: fv,
			// TIME:     t,
		}
		b3 := b.cache[id].fields[key]
		return b3.PushValue(field)
	}

	tmp := b.cache[id].fields[key]
	// https://en.m.wikipedia.org/wiki/Algorithms_for_calculating_variance
	// variable initialization
	// x := fv
	// mean := tmp.mean
	// m2 := tmp.M2
	// counter compute
	n := tmp.count + 1
	tmp.count = n
	// // mean compute
	// delta := x - mean
	// mean += delta / n // mean = mean + delta/n
	// tmp.mean = mean
	// // variance/stdev compute
	// // m2 = m2 + delta*(x-mean)
	// m2 += delta * (x - mean)
	// tmp.M2 = m2
	// // max/min compute
	// if fv < tmp.min {
	// 	tmp.min = fv
	// } else if fv > tmp.max {
	// 	tmp.max = fv
	// }
	// // sum compute
	// tmp.sum += fv
	// diff compute
	tmp.diff = fv - tmp.LAST
	// // interval compute
	// tmp.interval = t.Sub(tmp.TIME)
	// // rate compute
	// if !t.Equal(tmp.TIME) {
	// 	tmp.rate = tmp.diff / tmp.interval.Seconds()
	// }
	// tmp.TIME = t
	tmp.LAST = fv
	// store final data
	b.cache[id].fields[key] = tmp

	return tmp.PushValue(field)
}

// func (b *BasicStats2) GetValue(name, key, field string) (float64, bool) {
// 	id := name
// 	if _, ok := b.cache[id]; ok {
// 		if b3, ok := b.cache[id].fields[key]; ok {
// 			return b3.PushValue(field)
// 		}
// 	}
// 	return -1, false
// }

func (bs *basicstats2) PushValue(field string) (float64, bool) {
	switch field {
	// case "count":
	// 	return bs.count, true
	// case "min":
	// 	return bs.min, true
	// case "max":
	// 	return bs.max, true
	// case "mean":
	// 	return bs.mean, true
	// case "sum":
	// 	return bs.sum, true
	// case "s2":
	// 	if bs.count > 1 {
	// 		return bs.M2 / (bs.count - 1), true
	// 	}
	// 	return 0, false
	// case "stdev":
	// 	if bs.count > 1 {
	// 		return math.Sqrt(bs.M2 / (bs.count - 1)), true
	// 	}
	// 	return 0, false
	case "diff":
		return bs.diff, bs.count > 1 && bs.diff >= 0
	// case "rate":
	// 	return bs.rate, bs.count > 1
	// case "non_negative_diff":
	// 	return bs.diff, bs.count > 1 && bs.diff >= 0
	// case "non_negative_rate":
	// 	return bs.rate, bs.count > 1 && bs.diff >= 0
	// case "interval":
	// 	return float64(bs.interval.Nanoseconds()), bs.count > 1
	default:
		return 0, false
	}
}

func (b *BasicStats2) Reset() {
	b.cache = make(map[string]aggregate2)
}

func convert2(in interface{}) (float64, bool) {
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

func mapToString2(data map[string]interface{}) string {
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
