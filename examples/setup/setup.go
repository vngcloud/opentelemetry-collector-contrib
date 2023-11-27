// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	// Read database configuration from command line arguments
	if len(os.Args) != 4 {
		fmt.Println("Usage: setup <username> <password> <dsn>")
		os.Exit(1)
	}

	username := os.Args[1]
	password := os.Args[2]
	dsn := os.Args[3]

	// Open a database connection
	db, err := sql.Open("mysql", fmt.Sprintf("%s:%s@(%s)/mysql", username, password, dsn))
	// db, err := sql.Open("mysql", "root:mypass@tcp(localhost:3307)/mysql")
	if err != nil {
		fmt.Println("Error connecting to the database:", err)
		return
	}
	defer db.Close()

	_, err = db.Exec("create schema if not exists vmonitor;")
	if err != nil {
		fmt.Println(err)
		return
	}

	// List all schemas
	schemas, err := listSchemas(db)
	if err != nil {
		fmt.Println("Error listing schemas:", err)
		return
	}

	for _, schema := range schemas {
		fmt.Printf("Schema: %s\n", schema)

		// List all procedures in the current schema
		procedures, errr := listProcedures(db, schema)
		if errr != nil {
			fmt.Println("Error listing procedures:", errr)
			return
		}

		if schema != "mysql" && schema != "information_schema" && schema != "performance_schema" && schema != "sys" {
			fmt.Println("  Creating procedure explain_statement", schema)
			// check if have procedure explain_statement in this schema then delete
			if contains(procedures, "explain_statement") {
				// fmt.Println("  Deleting procedure explain_statement", schema)
				_, er := db.Exec(fmt.Sprintf("DROP PROCEDURE %s.explain_statement", schema))
				if er != nil {
					fmt.Println("Error deleting procedure:", er)
					return
				}
			}

			createProcedureSQL := "CREATE PROCEDURE %s.explain_statement(IN query TEXT) SQL SECURITY DEFINER BEGIN SET @explain := CONCAT('EXPLAIN FORMAT=json ', query); PREPARE stmt FROM @explain; EXECUTE stmt; DEALLOCATE PREPARE stmt; END;"
			_, er := db.Exec(fmt.Sprintf(createProcedureSQL, schema))
			if er != nil {
				fmt.Println(er)
				return
			}

			// List all procedures in the current schema
			procedures, er = listProcedures(db, schema)
			if er != nil {
				fmt.Println("Error listing procedures:", er)
				return
			}
		}

		for _, procedure := range procedures {
			fmt.Printf("  Procedure: %s\n", procedure)
		}
	}

	// setup runtime
	query := `UPDATE performance_schema.setup_consumers SET enabled='YES' WHERE name LIKE 'events_statements_%';`
	_, err = db.Query(query)
	if err != nil {
		fmt.Printf("Error setup run time (%s): %s", query, err.Error())
	}

	query = `UPDATE performance_schema.setup_consumers SET enabled='YES' WHERE name = 'events_waits_current';`
	_, err = db.Query(query)
	if err != nil {
		fmt.Printf("Error setup run time (%s): %s", query, err.Error())
	}
}

func listSchemas(db *sql.DB) ([]string, error) {
	rows, err := db.Query("SHOW DATABASES")
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

func listProcedures(db *sql.DB, schema string) ([]string, error) {
	query := `SELECT routine_name FROM information_schema.routines WHERE routine_type = 'PROCEDURE' AND routine_schema = ?`
	rows, err := db.Query(query, schema)
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

func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}
