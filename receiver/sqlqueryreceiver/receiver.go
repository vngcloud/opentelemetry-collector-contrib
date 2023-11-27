// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package sqlqueryreceiver // import "github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sqlqueryreceiver"

import (
	"context"
	"database/sql"

	"go.opentelemetry.io/collector/component"
	"go.opentelemetry.io/collector/consumer"
	"go.opentelemetry.io/collector/receiver"
)

type sqlOpenerFunc func(driverName, dataSourceName string) (*sql.DB, error)

type dbProviderFunc func() (*sql.DB, error)

func createLogsReceiverFunc(sqlOpenerFunc sqlOpenerFunc) receiver.CreateLogsFunc {
	return func(
		ctx context.Context,
		settings receiver.CreateSettings,
		config component.Config,
		consumer consumer.Logs,
	) (receiver.Logs, error) {
		sqlQueryConfig := config.(*Config)
		return newLogsReceiver(sqlQueryConfig, settings, sqlOpenerFunc, consumer)
	}
}
