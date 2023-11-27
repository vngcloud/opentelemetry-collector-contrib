// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Package vmonitorexporter contains an opentelemetry-collector exporter
// for Elasticsearch.
package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"context"
	"fmt"
	"strconv"
	"sync"
	"time"

	"github.com/sirupsen/logrus"
	"go.opentelemetry.io/collector/pdata/plog"

	"github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter/proxy"
)

type vmonitorLogsExporter struct {
	output          *VNGCloudvMonitor
	buf             *Buffer
	aggMutex        sync.Mutex
	MetricBatchSize int
	flushInterval   int // second
	basicstats      BasicStats2
	hostname        string
	dimensionKeys   []string
	valueKeys       []string
}

func newLogsExporter(cfg *Config) (*vmonitorLogsExporter, error) {
	if err := cfg.Validate(); err != nil {
		return nil, err
	}
	infoHosts := &infoHost{
		// Plugins: map[string]*Plugin{
		// 	"haha": nil,
		// },
		Plugins:     []Plugin{},
		PluginsList: make(map[string]bool),
		HashID:      "",
		Kernel:      "",
		Core:        "",
		Platform:    "",
		OS:          "",
		Hostname:    cfg.Hostname,
		CPUs:        0,
		Mem:         0,
	}

	outputs := &VNGCloudvMonitor{
		Timeout:         defaultConfig.Timeout,
		URL:             cfg.Endpoint,
		IamURL:          cfg.IamURL,
		ClientID:        cfg.ClientID,
		ClientSecret:    cfg.ClientSecret,
		checkQuotaRetry: defaultConfig.checkQuotaRetry,
		infoHost:        infoHosts,
		httpProxy: proxy.HTTPProxy{
			HTTPProxyURL:   cfg.HTTPProxyURL,
			UseSystemProxy: cfg.UseSystemProxy,
		},
		dropCount:       1,
		dropTime:        time.Now(),
		checkQuotaFirst: false,
		ContentEncoding: cfg.ContentEncoding,
	}

	err := outputs.Connect()
	if err != nil {
		logrus.Errorf("Error connect output %s.\n", err.Error())
		return nil, err
	}

	vMetricsExp := &vmonitorLogsExporter{
		output:          outputs,
		buf:             NewBuffer(cfg.MetricBufferLimit),
		MetricBatchSize: cfg.MetricBatchSize,
		hostname:        cfg.Hostname,
		flushInterval:   cfg.FlushInterval,
		basicstats:      NewBasicStats2Processor(),
		dimensionKeys:   cfg.Logs2Metrics.DimensionKeys,
		valueKeys:       cfg.Logs2Metrics.ValueKeys,
	}
	return vMetricsExp, nil
	// vMetricsExp := &vmonitorLogsExporter{}
	// return vMetricsExp, nil
}

func (e *vmonitorLogsExporter) Shutdown(_ context.Context) error {
	return nil
}

func (e *vmonitorLogsExporter) pushLogsData(_ context.Context, ld plog.Logs) error {
	rlss := ld.ResourceLogs()
	for i := 0; i < rlss.Len(); i++ {
		rls := rlss.At(i)
		slss := rls.ScopeLogs()

		for i := 0; i < slss.Len(); i++ {
			sls := slss.At(i)

			slsl := sls.LogRecords()
			for j := 0; j < slsl.Len(); j++ {
				l := slsl.At(j)
				m := e.log2metric(l.Attributes().AsRaw(), l.Timestamp().AsTime())
				e.writeToBuffer(m)
			}
		}
	}
	return e.writeBatch()
}

func (e *vmonitorLogsExporter) writeToBuffer(ms []Metric) {
	e.aggMutex.Lock()
	e.buf.Add(ms)
	e.aggMutex.Unlock()
}

func (e *vmonitorLogsExporter) log2metric(logs map[string]any, tm time.Time) []Metric {
	var metrics []Metric

	for _, valueKey := range e.valueKeys {
		value, err := anyToFloat64(logs[valueKey])
		if err != nil {
			continue
		}
		metric := Metric{
			Name:       fmt.Sprintf("annd2_%s_diff", valueKey),
			Dimensions: make(Dimensions),
			Value:      -1,
			Timestamp:  float64(tm.UnixNano() / int64(time.Millisecond)),
			ValueMeta:  make(ValueMeta),
		}

		for _, dimensionKey := range e.dimensionKeys {
			dimensionV, _ := SanitizeDimensionValue(fmt.Sprintf("%v", logs[dimensionKey]))
			if dimensionV == "" {
				dimensionV = "N/A"
			}
			metric.Dimensions[dimensionKey] = dimensionV
		}
		stat, ok := e.basicstats.ProcessValue(valueKey, mapToString2(metric.Dimensions), "diff", value)
		if !ok {
			if stat < 0 {
				logrus.Errorf("Error process key: %s, value: %v\n", valueKey, stat)
			}
			continue
		}
		metric.Value = stat
		metric.Dimensions["host"] = e.hostname

		metrics = append(metrics, metric)
	}

	return metrics
}

func (e *vmonitorLogsExporter) writeBatch() error {
	nBuffer := e.buf.Len()
	nBatches := nBuffer/e.MetricBatchSize + 1
	logrus.Infof("Writing %d metric(s) in %d batch(es)\n", nBuffer, nBatches)
	for i := 0; i < nBatches; i++ {
		if i != 0 && e.flushInterval > 0 {
			time.Sleep(time.Duration(e.flushInterval) * time.Second)
		}

		batch := e.buf.Batch(e.MetricBatchSize)
		if len(batch) == 0 {
			break
		}

		err := e.writeMetrics(batch)
		if err != nil {
			e.buf.Reject(batch)
			return err
		}
		e.buf.Accept(batch)
	}
	return nil
}

func (e *vmonitorLogsExporter) writeMetrics(md []Metric) error {
	err := e.output.WriteBatch(md)
	if err == nil {
		logrus.Infof("Wrote batch %d metric(s)", len(md))
	}
	return err
}
func anyToFloat64(value interface{}) (float64, error) {
	switch v := value.(type) {
	case int:
		return float64(v), nil
	case int32:
		return float64(v), nil
	case int64:
		return float64(v), nil
	case float32:
		return float64(v), nil
	case float64:
		return v, nil
	case bool:
		if v {
			return 1.0, nil
		}
		return 0.0, nil
	case string:
		metricValue, err := strconv.ParseFloat(v, 64)
		if err != nil {
			return -2, fmt.Errorf("cannot convert string %T to float64", value)
		}
		return metricValue, nil
	default:
		return -1, fmt.Errorf("cannot convert default %T to float64", value)
	}
}
