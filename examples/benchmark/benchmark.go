// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"database/sql"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

type DBCase struct {
	Queries []string
}

var DBCASE = []DBCase{
	// {
	// 	Queries: []string{
	// 		"UPDATE performance_schema.setup_consumers SET enabled='NO';",
	// 		"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'events_statements_current';",
	// 		"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'events_statements_history';",
	// 		"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'events_transactions_current';",
	// 		"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'events_transactions_history';",
	// 		"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'global_instrumentation';",
	// 		"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'thread_instrumentation';",
	// 		"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'statements_digest';",
	// 	},
	// },
	{ // all disable
		Queries: []string{
			"UPDATE performance_schema.setup_consumers SET enabled='NO';",
			"UPDATE performance_schema.setup_instruments SET enabled='NO';",
		},
	},
	{ // all enable
		Queries: []string{
			"UPDATE performance_schema.setup_consumers SET enabled='YES';",
			"UPDATE performance_schema.setup_instruments SET enabled='YES';",
		},
	},
	{ // statements only
		Queries: []string{
			"UPDATE performance_schema.setup_consumers SET enabled='NO';",
			"UPDATE performance_schema.setup_instruments SET enabled='NO';",

			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'global_instrumentation';",
			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'thread_instrumentation';",
			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME like 'events_statements_%';",
			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'statements_digest';",
			"UPDATE performance_schema.setup_instruments SET enabled='YES' where NAME like 'statement%';",
		},
	},
	{ // wait only
		Queries: []string{
			"UPDATE performance_schema.setup_consumers SET enabled='NO';",
			"UPDATE performance_schema.setup_instruments SET enabled='NO';",

			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'global_instrumentation';",
			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'thread_instrumentation';",
			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME like 'events_waits%';",
			"UPDATE performance_schema.setup_instruments SET enabled='YES' where NAME like 'wait%';",
		},
	},
	{ // statement + wait only
		Queries: []string{
			"UPDATE performance_schema.setup_consumers SET enabled='NO';",
			"UPDATE performance_schema.setup_instruments SET enabled='NO';",

			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'global_instrumentation';",
			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'thread_instrumentation';",
			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME like 'events_waits%';",
			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME like 'events_statements_%';",
			"UPDATE performance_schema.setup_consumers SET enabled='YES' where NAME = 'statements_digest';",
			"UPDATE performance_schema.setup_instruments SET enabled='YES' where NAME like 'wait%';",
			"UPDATE performance_schema.setup_instruments SET enabled='YES' where NAME like 'statement%';",
		},
	},
}

var ThreadOnlyRead = []int{1, 8, 16, 32, 48, 64, 128, 192, 256, 320, 384, 448, 512}
var ThreadReadWrite = []int{1, 4, 8, 16, 24, 32, 40, 48, 56, 64, 128, 192, 256, 320, 384, 448, 512}
var DBNameConnect = "mysql"

const (
	DBUser     = "annd2"
	DBPassword = "________________________"
	DBHost     = "127.0.0.1"
	DBPort     = "3306"
	// createProcedureSQL = "CREATE DEFINER=annd2@'%%' PROCEDURE %s.explain_statement(IN query TEXT) BEGIN SET @explain := CONCAT('EXPLAIN FORMAT=json ', query); PREPARE stmt FROM @explain; EXECUTE stmt;DEALLOCATE PREPARE stmt; END;"
	createProcedureSQL = "CREATE PROCEDURE %s.explain_statement(IN query TEXT) SQL SECURITY DEFINER BEGIN SET @explain := CONCAT('EXPLAIN FORMAT=json ', query); PREPARE stmt FROM @explain; EXECUTE stmt; DEALLOCATE PREPARE stmt; END;"
	TIME               = "300"
	THREAD             = "1024"
	TABLE              = "500"
	TABLESIZE          = "500000"
	cmdSysbench        = "sysbench"
)

func ExecStatement(query string) {
	fmt.Println(time.Now(), "ExecStatement", query)
	db, err := sql.Open("mysql", fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", DBUser, DBPassword, DBHost, DBPort, DBNameConnect))
	if err != nil {
		fmt.Println(err)
		return
	}
	defer db.Close()

	_, err = db.Exec(query)
	if err != nil {
		fmt.Println(err)
		return
	}
}

func runCommandWithOutput(cmdName string, cmdArgs []string, outputFile string) {
	// fmt.Println(time.Now(), "runCommandWithOutput", cmdName, cmdArgs, outputFile)
	// Create a command object
	cmd := exec.Command(cmdName, cmdArgs...)

	// Extract the directory path from the file path
	dirPath := filepath.Dir(outputFile)
	if err := os.MkdirAll(dirPath, os.ModePerm); err != nil {
		fmt.Println("Error creating directory:", err)
		return
	}

	// Create a file to capture the command's output
	file, err := os.Create(outputFile)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer file.Close()

	// Set the output to be captured
	cmd.Stdout = file
	cmd.Stderr = file

	// Run the command
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
		return
	}
}

func runCommand(cmdName string, cmdArgs []string) error {
	// fmt.Println(time.Now(), "runCommandWithOutput", cmdName, cmdArgs, outputFile)
	// Create a command object
	cmd := exec.Command(cmdName, cmdArgs...)

	// Run the command and capture its output
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("Error running command:", err)
		return err
	}

	// Convert the output to a string and print it
	outputString := string(output)
	fmt.Print(outputString)
	return nil
}

// func prepare(result string) {
// 	fmt.Println(time.Now(), "prepare")
// 	var cmdPrepare = []string{"oltp_read_write", fmt.Sprintf("--mysql-host=%s", DBHost), fmt.Sprintf("--mysql-user=%s", DBUser), fmt.Sprintf("--mysql-password=%s", DBPassword), fmt.Sprintf("--mysql-port=%s", DBPort), fmt.Sprintf("--mysql-db=%s", DBName), fmt.Sprintf("--threads=%s", THREAD), fmt.Sprintf("--tables=%s", TABLE), fmt.Sprintf("--table-size=%s", TABLESIZE), "prepare"}

// 	ExecStatement(fmt.Sprintf("drop schema if exists %s", DBName))
// 	ExecStatement(fmt.Sprintf("create schema %s", DBName))
// 	ExecStatement(fmt.Sprintf(createProcedureSQL, DBName))
// 	runCommandWithOutput(cmdSysbench, cmdPrepare, fmt.Sprintf("%s-p.txt", result))
// 	time.Sleep(10 * time.Second)
// }

func sysbenchRead(thread int, result string) {
	fmt.Println(time.Now(), "sysbenchRead")
	var cmdreadArgs = []string{"oltp_read_only", fmt.Sprintf("--mysql-host=%s", DBHost), fmt.Sprintf("--mysql-user=%s", DBUser), fmt.Sprintf("--mysql-password=%s", DBPassword), fmt.Sprintf("--mysql-port=%s", DBPort), fmt.Sprintf("--mysql-db=%s", DBName), fmt.Sprintf("--threads=%d", thread), fmt.Sprintf("--tables=%s", TABLE), fmt.Sprintf("--table-size=%s", TABLESIZE), "--range_selects=off", "--db-ps-mode=disable", fmt.Sprintf("--time=%s", TIME), "run"}
	runCommandWithOutput(cmdSysbench, cmdreadArgs, result)
}

// func sysbenchWrite(result string) {
// 	fmt.Println(time.Now(), "sysbenchWrite")
// 	var cmdwriteArgs = []string{"oltp_write_only", fmt.Sprintf("--mysql-host=%s", DBHost), fmt.Sprintf("--mysql-user=%s", DBUser), fmt.Sprintf("--mysql-password=%s", DBPassword), fmt.Sprintf("--mysql-port=%s", DBPort), fmt.Sprintf("--mysql-db=%s", DBName), fmt.Sprintf("--threads=%s", thread), fmt.Sprintf("--tables=%s", TABLE), fmt.Sprintf("--table-size=%s", TABLESIZE), "--range_selects=off", "--db-ps-mode=disable", fmt.Sprintf("--time=%s", TIME), "run"}
// 	runCommandWithOutput(cmdSysbench, cmdwriteArgs, fmt.Sprintf("%s", result))
// }

// func sysbenchBoth(thread int, result string) {
// 	fmt.Println(time.Now(), "sysbenchBoth")
// 	var cmdbothArgs = []string{"oltp_read_write", fmt.Sprintf("--mysql-host=%s", DBHost), fmt.Sprintf("--mysql-user=%s", DBUser), fmt.Sprintf("--mysql-password=%s", DBPassword), fmt.Sprintf("--mysql-port=%s", DBPort), fmt.Sprintf("--mysql-db=%s", DBName), fmt.Sprintf("--threads=%d", thread), fmt.Sprintf("--tables=%s", TABLE), fmt.Sprintf("--table-size=%s", TABLESIZE), "--range_selects=off", "--db-ps-mode=disable", fmt.Sprintf("--time=%s", TIME), "run"}
// 	runCommandWithOutput(cmdSysbench, cmdbothArgs, result)
// }

var DBName = "super"

func main() {
	var rootResult = "./no-agent-read-1"
	var SYSBENCHCASE = ThreadOnlyRead
	// prepare(fmt.Sprintf("%s/prepare", rootResult))
	for dbIndex, dbCase := range DBCASE {
		fmt.Println("----- CASE", dbIndex)
		for _, query := range dbCase.Queries {
			ExecStatement(query)
		}
		for _, thread := range SYSBENCHCASE {
			sysbenchRead(thread, fmt.Sprintf("%s/%d/%d-r.txt", rootResult, dbIndex, thread))
		}
	}

	for dbIndex := range DBCASE {
		fmt.Println("----- CASE", dbIndex)
		for _, thread := range SYSBENCHCASE {
			err := runCommand("python3", []string{"read_file.py", fmt.Sprintf("%s/%d/%d-r.txt", rootResult, dbIndex, thread)})
			if err != nil {
				fmt.Println(err)
			}
		}
	}
}
