// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Package vmonitorexporter contains an opentelemetry-collector exporter
// for Elasticsearch.
package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/sirupsen/logrus"
	"go.opentelemetry.io/collector/pdata/pmetric"

	"github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter/proxy"
)

type vmonitorMetricsExporter struct {
	output          *VNGCloudvMonitor
	buf             *Buffer
	aggMutex        sync.Mutex
	MetricBatchSize int
	serializer      Serializer
	flushInterval   int // second
}

func newMetricsExporter(cfg *Config) (*vmonitorMetricsExporter, error) {
	fmt.Println("--------- newMetricsExporter")
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
		fmt.Println(err)
		return nil, err
	}

	vMetricsExp := &vmonitorMetricsExporter{
		output:          outputs,
		buf:             NewBuffer(cfg.MetricBufferLimit),
		MetricBatchSize: cfg.MetricBatchSize,
		serializer:      NewSerializer(cfg.Hostname),
		flushInterval:   cfg.FlushInterval,
	}
	return vMetricsExp, nil
}

func (e *vmonitorMetricsExporter) Shutdown(_ context.Context) error {
	return nil
}

func (e *vmonitorMetricsExporter) pushMetricsData(_ context.Context, md pmetric.Metrics) error {
	e.aggMutex.Lock()
	metrics := e.serializer.Serialize(md)

	e.buf.Add(metrics)
	e.aggMutex.Unlock()
	// e.output.Write(md)
	err := e.writeBatch()
	return err
}

func (e *vmonitorMetricsExporter) writeBatch() error {
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

func (e *vmonitorMetricsExporter) writeMetrics(md []Metric) error {
	err := e.output.WriteBatch(md)
	if err == nil {
		logrus.Infof("Wrote batch %+v metric(s)\n", len(md))
	}
	return err
	// return fmt.Errorf("foo error")
}
