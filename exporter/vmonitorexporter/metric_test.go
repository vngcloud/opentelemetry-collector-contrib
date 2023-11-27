// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Package vmonitorexporter contains an opentelemetry-collector exporter
// for Elasticsearch.
package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func shim(a, b interface{}) []interface{} {
	return []interface{}{a, b}
}
func TestValidString(t *testing.T) {
	assert.Equal(t, shim(valid("cpu<", IsMetricName)), shim("cpu_", true))
	assert.Equal(t, shim(valid("cpu<<", IsMetricName)), shim("cpu_", true))
	assert.Equal(t, shim(valid("cpu<a<", IsMetricName)), shim("cpu_a_", true))
	assert.Equal(t, shim(valid("<cpu<", IsMetricName)), shim("_cpu_", true))
	assert.Equal(t, shim(valid("0cpu", IsMetricName)), shim("_cpu", true))
	assert.Equal(t, shim(valid("5cpu", IsMetricName)), shim("_cpu", true))
	assert.Equal(t, shim(valid("-cpu", IsMetricName)), shim("_cpu", true))
	assert.Equal(t, shim(valid(".cpu", IsMetricName)), shim("_cpu", true))
	assert.Equal(t, shim(valid("select * from db", IsMetricName)), shim("select_from_db", true))

	assert.Equal(t, validDimensionValue("SELECT COALESCE ( `SCHEMA_NAME` , ? ) AS SCHEMA_NAME , `DIGEST_TEXT` , `COUNT_STAR` AS `annd2_count_star` , `SUM_ROWS_SENT` AS `annd2_sum_rows_sent` , `SUM_TIMER_WAIT` / ? AS `annd2_sum_timer_wait_ms` FROM `performance_schema` . `events_statements_summary_by_digest`"),
		"SELECT_COALESCE_SCHEMA_NAME_AS_SCHEMA_NAME_DIGEST_TEXT_COUNT_STAR_AS_annd2_count_star_SUM_ROWS_SENT_AS_annd2_sum_rows_sent_SUM_TIMER_WAIT_/_AS_annd2_sum_timer_wait_ms_FROM_performance_schema_._events_statements_summary")
	// assert.Equal(t, "hihi", "haha")
}
