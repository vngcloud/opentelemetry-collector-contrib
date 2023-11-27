// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package sqlqueryreceiver // import "github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sqlqueryreceiver"

import (
	"container/list"
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/DataDog/go-sqllexer"
	"github.com/sirupsen/logrus"
	"go.opentelemetry.io/collector/component"
	"go.opentelemetry.io/collector/consumer"
	"go.opentelemetry.io/collector/extension/experimental/storage"
	"go.opentelemetry.io/collector/obsreport"
	"go.opentelemetry.io/collector/pdata/pcommon"
	"go.opentelemetry.io/collector/pdata/plog"
	"go.opentelemetry.io/collector/receiver"
	"go.uber.org/multierr"
	"go.uber.org/zap"

	"github.com/open-telemetry/opentelemetry-collector-contrib/pkg/stanza/adapter"
	"github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sqlqueryreceiver/internal/metadata"
)

var commandRegex = regexp.MustCompile(`/\*.*?\*/`)
var conditionRegex = regexp.MustCompile(`"attached_condition": ".*?"`)

type stringMap map[string]string

type logsReceiver struct {
	config           *Config
	settings         receiver.CreateSettings
	createConnection dbProviderFunc
	queryReceivers   []*logsQueryReceiver
	nextConsumer     consumer.Logs

	isStarted                bool
	collectionIntervalTicker *time.Ticker
	shutdownRequested        chan struct{}

	id            component.ID
	storageClient storage.Client
	obsrecv       *obsreport.Receiver

	db         *sql.DB
	obfuscator *sqllexer.Obfuscator
}

func newLogsReceiver(
	config *Config,
	settings receiver.CreateSettings,
	sqlOpenerFunc sqlOpenerFunc,
	nextConsumer consumer.Logs,
) (*logsReceiver, error) {

	obsr, err := obsreport.NewReceiver(obsreport.ReceiverSettings{
		ReceiverID:             settings.ID,
		ReceiverCreateSettings: settings,
	})
	if err != nil {
		return nil, err
	}

	receiver := &logsReceiver{
		config:   config,
		settings: settings,
		createConnection: func() (*sql.DB, error) {
			return sqlOpenerFunc(config.Driver, config.DataSource)
		},
		nextConsumer:      nextConsumer,
		shutdownRequested: make(chan struct{}),
		id:                settings.ID,
		obsrecv:           obsr,
		obfuscator:        sqllexer.NewObfuscator(),
	}

	return receiver, nil
}

func (receiver *logsReceiver) Start(ctx context.Context, host component.Host) error {
	if receiver.isStarted {
		receiver.settings.Logger.Debug("requested start, but already started, ignoring.")
		return nil
	}
	receiver.settings.Logger.Debug("starting...")
	receiver.isStarted = true

	var err error
	receiver.storageClient, err = adapter.GetStorageClient(ctx, host, receiver.config.StorageID, receiver.settings.ID)
	if err != nil {
		return fmt.Errorf("error connecting to storage: %w", err)
	}

	receiver.db, err = receiver.createConnection()
	if err != nil {
		return fmt.Errorf("error connecting to database: %w", err)
	}
	// receiver.db.SetConnMaxLifetime(10 * time.Second)
	receiver.db.SetMaxIdleConns(1)
	receiver.db.SetMaxOpenConns(1)
	receiver.checkRequirement()
	err = receiver.createQueryReceivers()
	if err != nil {
		return err
	}

	for _, queryReceiver := range receiver.queryReceivers {
		err := queryReceiver.start(ctx)
		if err != nil {
			return err
		}
	}
	receiver.startCollecting()
	receiver.settings.Logger.Debug("started.")
	return nil
}

func (receiver *logsReceiver) checkRequirement() {
	// 1. Turn on performance_schema
	checkPerformanceSchema := func(variable string, expect string) {
		var variableName, variableValue string
		query := fmt.Sprintf("SHOW VARIABLES LIKE '%s'", variable)
		err := receiver.db.QueryRow(query).Scan(&variableName, &variableValue)
		if err != nil {
			logrus.Errorln("Error QueryRow:", query, err)
			return
		}
		if variableValue == expect {
			logrus.Infof("pass: %s=%s", variable, expect)
		} else {
			logrus.Warnf("fail: %s=%s (expect=%s)", variable, variableValue, expect)
		}

	}
	checkPerformanceSchema("performance_schema", "ON")
	checkPerformanceSchema("performance_schema_max_digest_length", "4096")
	checkPerformanceSchema("performance_schema_max_sql_text_length", "4096")

	// 2. Create vmonitor database
	checkExistVmonitor := func() {
		schemaToCheck := "vmonitor"
		var schemaCount int
		query := "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = ?"
		err := receiver.db.QueryRow(query, schemaToCheck).Scan(&schemaCount)
		if err != nil {
			logrus.Errorln("Error QueryRow:", query, err)
			return
		}

		if schemaCount > 0 {
			logrus.Infof("pass: Schema '%s' exists.\n", schemaToCheck)
		} else {
			logrus.Warnf("fail: Schema '%s' does not exist. Please refer to the docs: ............................\n", schemaToCheck)
		}
	}
	checkExistVmonitor()

	// 3. Create explain_statement for every database
	listSchemas := func() ([]string, error) {
		rows, err := receiver.db.Query("SHOW DATABASES")
		if err != nil {
			return nil, err
		}
		defer rows.Close()

		var schemas []string
		for rows.Next() {
			var schema string
			if err := rows.Scan(&schema); err == nil {
				schemas = append(schemas, schema)
			}
		}
		return schemas, nil
	}
	listProcedures := func(schema string) ([]string, error) {
		query := `SELECT routine_name FROM information_schema.routines WHERE routine_type = 'PROCEDURE' AND routine_schema = ?`
		rows, err := receiver.db.Query(query, schema)
		if err != nil {
			return nil, err
		}
		defer rows.Close()

		var procedures []string
		for rows.Next() {
			var name string
			if err := rows.Scan(&name); err == nil {
				procedures = append(procedures, name)
			}
		}
		return procedures, nil
	}
	contains := func(s []string, e string) bool {
		for _, a := range s {
			if a == e {
				return true
			}
		}
		return false
	}
	checkProcedures := func() {
		schemas, err := listSchemas()
		if err != nil {
			logrus.Warnf("Error listing schemas: %s", err.Error())
			return
		}

		for _, schema := range schemas {
			procedures, err := listProcedures(schema)
			if err != nil {
				logrus.Warnf("Error listing procedures in schema %s, err: %s", schema, err.Error())
				continue
			}

			if schema != "mysql" && schema != "information_schema" && schema != "performance_schema" && schema != "sys" {
				if contains(procedures, "explain_statement") {
					logrus.Infof("pass: have procedure `explain_statement` in schema `%s`", schema)
				} else {
					logrus.Warnf("fail: missing procedure `explain_statement` in schema `%s`. Please refer to the docs: ............................", schema)
				}

				// createProcedureSQL := "CREATE PROCEDURE %s.explain_statement(IN query TEXT) SQL SECURITY DEFINER BEGIN SET @explain := CONCAT('EXPLAIN FORMAT=json ', query); PREPARE stmt FROM @explain; EXECUTE stmt; DEALLOCATE PREPARE stmt; END;"
				// _, er := receiver.db.Exec(fmt.Sprintf(createProcedureSQL, schema))
				// if er != nil {
				// 	logrus.Errorf("Error createProcedureSQL in schema %s, err: %s", schema, err)
				// 	continue
				// }
			}
		}
	}
	checkProcedures()
	// 4. Update runtime consume
	checkRuntimeConsume := func(variable string) {
		var variableName, variableValue string
		query := "SELECT NAME, ENABLED FROM performance_schema.setup_consumers where NAME = ?"
		err := receiver.db.QueryRow(query, variable).Scan(&variableName, &variableValue)
		if err != nil {
			logrus.Errorln("Error QueryRow:", query, err)
			return
		}
		if variableValue == "YES" {
			logrus.Infof("pass: %s=YES", variable)
		} else {
			logrus.Warnf("fail: %s=%s (expect=YES)", variable, variableValue)
		}
	}
	checkRuntimeConsume("events_waits_current")
	checkRuntimeConsume("events_statements_cpu")
	checkRuntimeConsume("events_statements_current")
	checkRuntimeConsume("events_statements_history")
	checkRuntimeConsume("events_statements_history_long")
}

func (receiver *logsReceiver) createQueryReceivers() error {
	receiver.queryReceivers = nil
	for i, query := range receiver.config.Queries {
		if len(query.Logs) == 0 {
			continue
		}
		id := fmt.Sprintf("query-%d: %s", i, query.SQL)
		queryReceiver := newLogsQueryReceiver(
			id,
			query,
			receiver.obfuscator,
		)
		receiver.queryReceivers = append(receiver.queryReceivers, queryReceiver)
	}
	return nil
}

func (receiver *logsReceiver) startCollecting() {
	receiver.collectionIntervalTicker = time.NewTicker(receiver.config.CollectionInterval)

	go func() {
		for {
			select {
			case <-receiver.collectionIntervalTicker.C:
				receiver.collect()
			case <-receiver.shutdownRequested:
				return
			}
		}
	}()
}

func (receiver *logsReceiver) collect() {
	logsChannel := make(chan plog.Logs)
	for _, queryReceiver := range receiver.queryReceivers {
		go func(queryReceiver *logsQueryReceiver) {
			logs, err := queryReceiver.collect(context.Background(), receiver.db)
			if err != nil {
				receiver.settings.Logger.Error("error collecting logs", zap.Error(err), zap.String("query", queryReceiver.ID()))
			}
			logsChannel <- logs
		}(queryReceiver)
	}

	allLogs := plog.NewLogs()
	for range receiver.queryReceivers {
		logs := <-logsChannel
		logs.ResourceLogs().MoveAndAppendTo(allLogs.ResourceLogs())
	}

	logRecordCount := allLogs.LogRecordCount()
	if logRecordCount > 0 {
		ctx := receiver.obsrecv.StartLogsOp(context.Background())
		err := receiver.nextConsumer.ConsumeLogs(context.Background(), allLogs)
		receiver.obsrecv.EndLogsOp(ctx, metadata.Type, logRecordCount, err)
		if err != nil {
			receiver.settings.Logger.Error("failed to send logs: %w", zap.Error(err))
		}
	}
}

func (receiver *logsReceiver) Shutdown(ctx context.Context) error {
	if !receiver.isStarted {
		receiver.settings.Logger.Debug("Requested shutdown, but not started, ignoring.")
		return nil
	}

	receiver.settings.Logger.Debug("stopping...")
	receiver.stopCollecting()
	for _, queryReceiver := range receiver.queryReceivers {
		queryReceiver.shutdown(ctx)
	}
	receiver.db.Close()

	var errors error
	if receiver.storageClient != nil {
		errors = multierr.Append(errors, receiver.storageClient.Close(ctx))
	}

	receiver.isStarted = false
	receiver.settings.Logger.Debug("stopped.")

	return errors
}

func (receiver *logsReceiver) stopCollecting() {
	if receiver.collectionIntervalTicker != nil {
		receiver.collectionIntervalTicker.Stop()
	}
	close(receiver.shutdownRequested)
}

type logsQueryReceiver struct {
	id    string
	query Query

	trackingDigest map[string]any
	maxSize        int
	order          *list.List
	prepareStmt    *sql.Stmt
	obfuscator     *sqllexer.Obfuscator
}

func newLogsQueryReceiver(
	id string,
	query Query,
	_obfuscator *sqllexer.Obfuscator,
) *logsQueryReceiver {
	queryReceiver := &logsQueryReceiver{
		id:    id,
		query: query,

		trackingDigest: make(map[string]any),
		maxSize:        100,
		order:          list.New(),
		prepareStmt:    nil,
		obfuscator:     _obfuscator,
	}
	return queryReceiver
}

func (queryReceiver *logsQueryReceiver) ID() string {
	return queryReceiver.id
}

func (queryReceiver *logsQueryReceiver) start(_ context.Context) error {
	return nil
}

func (queryReceiver *logsQueryReceiver) collect(ctx context.Context, sqlDB *sql.DB) (plog.Logs, error) {
	logs := plog.NewLogs()
	observedAt := pcommon.NewTimestampFromTime(time.Now())

	if queryReceiver.prepareStmt == nil {
		var err error
		queryReceiver.prepareStmt, err = sqlDB.PrepareContext(ctx, queryReceiver.query.SQL)
		if err != nil {
			logrus.Errorln("Error PrepareContext:", queryReceiver.query.SQL, err)
			return logs, err
		}
	}
	rowss, err := queryReceiver.prepareStmt.QueryContext(ctx)
	if err != nil {
		logrus.Errorln("Error QueryContext:", queryReceiver.query.SQL, err)
		rowss.Close()
		return logs, err
	}
	defer rowss.Close()
	rows, err := queryReceiver.sqlRowsToStringMap(rowss)
	if err != nil {
		logrus.Errorln("Error sqlRowsToStringMap:", queryReceiver.query.SQL, err)
		// return logs, err
	}

	var errs error
	scopeLogs := logs.ResourceLogs().AppendEmpty().ScopeLogs().AppendEmpty().LogRecords()
	for _, logsConfig := range queryReceiver.query.Logs {
		for _, row := range rows {
			//
			if logsConfig.BodyColumn == "explain" || logsConfig.BodyColumn == "explain_not_cached" {
				getExplain := func() string {
					if _, ok := row["QUERY_SAMPLE_TEXT"]; !ok {
						logrus.Errorf("`explain` or `explain_not_cached` need a column `QUERY_SAMPLE_TEXT` in query: `%s`", queryReceiver.query.SQL)
					}
					querySampleText := row["QUERY_SAMPLE_TEXT"]
					obfuscated := queryReceiver.obfuscator.Obfuscate(querySampleText)
					row["DIGEST_TEXT"] = obfuscated
					delete(row, "QUERY_SAMPLE_TEXT")

					expression, ok := refactorQuery(querySampleText)
					if !ok {
						return ""
					}

					digest := hashTo16Bytes(expression)
					row["query_signature"] = digest
					if explain, ok := queryReceiver.trackingDigest[digest]; ok && logsConfig.BodyColumn != "explain_not_cached" {
						return explain.(string)
					}

					dbName := row["SCHEMA_NAME"]
					if dbName == "" || dbName == "information_schema" || dbName == "mysql" || dbName == "performance_schema" || dbName == "sys" {
						dbName = "vmonitor"
					}
					query := fmt.Sprintf("CALL %s.explain_statement('%s');", dbName, expression)
					rows, err := sqlDB.QueryContext(ctx, query)
					if err != nil {
						logrus.Errorln("Error explain query:", query, err)
						return ""
					}
					defer rows.Close()
					res, err := queryReceiver.sqlRowsToStringMap(rows)
					if err != nil {
						logrus.Errorln("Error sqlRowsToStringMap:", query, err)
						if logsConfig.BodyColumn != "explain_not_cached" {
							queryReceiver.AddDigest(digest, "")
						}
						return ""
					}

					explain := refactorExplainResult(res[0]["EXPLAIN"])

					if logsConfig.BodyColumn != "explain_not_cached" {
						queryReceiver.AddDigest(digest, explain)
					}
					return explain
				}
				row["explain"] = getExplain()
			}

			logRecord := scopeLogs.AppendEmpty()
			rowToLog(row, logsConfig, logRecord)

			raw := map[string]any{}
			for key, value := range row {
				// fmt.Printf("Key: %s  Value: %s\n", key, value)
				raw[key] = value
			}
			err := logRecord.Attributes().FromRaw(raw)
			if err != nil {
				errs = multierr.Append(errs, err)
			}

			logRecord.SetObservedTimestamp(observedAt)
		}
	}
	return logs, nil
}

func (queryReceiver *logsQueryReceiver) sqlRowsToStringMap(sqlRows *sql.Rows) ([]stringMap, error) {
	sqlRowsW := rowsWrapper{sqlRows}

	var out []stringMap
	colTypes, err := sqlRowsW.ColumnTypes()
	if err != nil {
		return nil, err
	}
	scanner := newRowScanner(colTypes)
	var warnings error
	for sqlRowsW.Next() {
		err = scanner.scan(sqlRowsW)
		if err != nil {
			return nil, err
		}
		sm, scanErr := scanner.toStringMap()
		if scanErr != nil {
			warnings = multierr.Append(warnings, scanErr)
		}
		out = append(out, sm)
	}
	return out, warnings
}

func rowToLog(row stringMap, _ LogsCfg, logRecord plog.LogRecord) {
	rowInterface := make(map[string]interface{})
	for key, value := range row {
		rowInterface[key] = value
		// check if can convert to int
		if intValue, err := strconv.Atoi(value); err == nil {
			rowInterface[key] = intValue
		}
		// check if can convert to float
		if floatValue, err := strconv.ParseFloat(value, 64); err == nil {
			rowInterface[key] = floatValue
		}
	}
	jsonStr, _ := json.Marshal(rowInterface)
	err := logRecord.Body().FromRaw(jsonStr) // .SetStr(string(jsonStr))
	if err != nil {
		fmt.Println("Error: ", err)
	}
	logRecord.SetTimestamp(pcommon.NewTimestampFromTime(time.Now()))
}

func (queryReceiver *logsQueryReceiver) shutdown(_ context.Context) {
	queryReceiver.prepareStmt.Close()
	queryReceiver.prepareStmt = nil
}

func refactorQuery(query string) (string, bool) {
	// replace ' to "
	query = strings.ReplaceAll(query, "'", "\"")
	// remove comment
	query = commandRegex.ReplaceAllString(query, "")
	// strip space
	query = strings.TrimSpace(query)

	if (len(query) >= 3 && strings.EqualFold(query[:3], "set")) ||
		(len(query) >= 3 && strings.EqualFold(query[:3], "use")) ||
		(len(query) >= 4 && strings.EqualFold(query[:4], "call")) ||
		(len(query) >= 4 && strings.EqualFold(query[:4], "show")) ||
		(len(query) >= 4 && strings.EqualFold(query[:4], "drop")) ||
		(len(query) >= 5 && strings.EqualFold(query[:5], "begin")) ||
		(len(query) >= 6 && strings.EqualFold(query[:6], "create")) ||
		(len(query) >= 6 && strings.EqualFold(query[:6], "commit")) {
		return query, false
	}
	return query, true
}

func refactorExplainResult(exp string) string {
	exp = conditionRegex.ReplaceAllString(exp, "\"attached_condition\": \"\"")
	return exp
}

func (queryReceiver *logsQueryReceiver) AddDigest(key string, value any) {
	// Check if the map has reached its size limit
	if len(queryReceiver.trackingDigest) >= queryReceiver.maxSize {
		// Remove the oldest entry
		oldestElement := queryReceiver.order.Front()
		if oldestElement != nil {
			delete(queryReceiver.trackingDigest, oldestElement.Value.(string))
			queryReceiver.order.Remove(oldestElement)
		}
	}

	// Add the new entry
	queryReceiver.trackingDigest[key] = value
	queryReceiver.order.PushBack(key)
}

func hashTo16Bytes(input string) string {
	// Create a new SHA-256 hash
	hasher := sha256.New()

	// Write the input string to the hash
	hasher.Write([]byte(input))

	// Sum the hash and get the hash in bytes
	hashBytes := hasher.Sum(nil)

	// Convert the hash to a hexadecimal string
	hashString := hex.EncodeToString(hashBytes)

	// Take the first 16 characters of the hash
	hashString = hashString[:16]

	return hashString
}
