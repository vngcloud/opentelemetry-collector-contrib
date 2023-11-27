// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func MetricsArr(length int) []Metric {
	var metrics []Metric
	for i := 0; i < length; i++ {
		metrics = append(metrics, NewMetric())
	}
	return metrics
}

func TestBuffer_LenEmpty(t *testing.T) {
	b := NewBuffer(5)
	require.Equal(t, 0, b.Len())
}

func TestBuffer_LenOne(t *testing.T) {
	b := NewBuffer(5)
	b.Add(MetricsArr(1))
	require.Equal(t, 1, b.Len())
}

func TestBuffer_LenFull(t *testing.T) {
	b := NewBuffer(5)
	b.Add(MetricsArr(5))
	require.Equal(t, 5, b.Len())
}

func TestBuffer_LenOverfill(t *testing.T) {
	b := NewBuffer(5)
	b.Add(MetricsArr(6))
	require.Equal(t, 5, b.Len())
}

func TestBuffer_BatchLenZero(t *testing.T) {
	b := NewBuffer(5)
	batch := b.Batch(0)
	require.Len(t, batch, 0)
}

func TestBuffer_BatchLenBufferEmpty(t *testing.T) {
	b := NewBuffer(5)
	batch := b.Batch(2)
	require.Len(t, batch, 0)
}

func TestBuffer_BatchLenUnderfill(t *testing.T) {
	b := NewBuffer(5)
	b.Add(MetricsArr(1))
	batch := b.Batch(2)
	require.Len(t, batch, 1)
}

func TestBuffer_BatchLenFill(t *testing.T) {
	b := NewBuffer(5)
	b.Add(MetricsArr(3))
	batch := b.Batch(2)
	require.Len(t, batch, 2)
}

func TestBuffer_BatchLenExact(t *testing.T) {
	b := NewBuffer(5)
	b.Add(MetricsArr(2))
	batch := b.Batch(2)
	require.Len(t, batch, 2)
}

func TestBuffer_BatchLenLargerThanBuffer(t *testing.T) {
	b := NewBuffer(5)
	b.Add(MetricsArr(5))
	batch := b.Batch(6)
	require.Len(t, batch, 5)
}

func TestBuffer_BatchWrap(t *testing.T) {
	b := NewBuffer(5)
	b.Add(MetricsArr(5))
	batch := b.Batch(2)
	b.Accept(batch)
	b.Add(MetricsArr(2))
	batch = b.Batch(5)
	require.Len(t, batch, 5)
}
