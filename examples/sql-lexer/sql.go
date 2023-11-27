// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"fmt"

	"github.com/DataDog/go-sqllexer"
)

func main() {
	query := "/*fdsaf*/ SELECT * from users WHERE id in (?, ?)"
	normalizer := sqllexer.NewNormalizer(
		sqllexer.WithRemoveSpaceBetweenParentheses(true),
		sqllexer.WithUppercaseKeywords(true),

		sqllexer.WithCollectCommands(true),
		sqllexer.WithCollectComments(true),
		sqllexer.WithCollectTables(true),
		sqllexer.WithCollectProcedures(true),
		sqllexer.WithKeepSQLAlias(true),
	)
	normalized, _, _ := normalizer.Normalize(query)
	// "SELECT * FROM users WHERE id in (?)"
	fmt.Println(normalized)
}

// import (
//     "fmt"
//     "github.com/DataDog/go-sqllexer"
// )

// func main() {
//     query := "/*fdsaf*/ SELECT * FROM users WHERE id = 1"
//     obfuscator := sqllexer.NewObfuscator(
// 		sqllexer.WithDollarQuotedFunc(true),
// 		sqllexer.WithReplacePositionalParameter(true),

// 	)
//     obfuscated := obfuscator.Obfuscate(query)
//     // "SELECT * FROM users WHERE id = ?"
//     fmt.Println(obfuscated)
// }
