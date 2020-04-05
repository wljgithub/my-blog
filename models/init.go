package models

import (
	"database/sql"
	"fmt"
	"github.com/go-gorp/gorp"
	"github.com/op/go-logging"
	"my-blog/common"
	"my-blog/logger"
)

var mysql *gorp.DbMap
var slog *logging.Logger

func init() {
	initDb()
	initLoger()
}

func initDb() {
	var dbConfig = common.Config.DB
	var url = fmt.Sprintf("%s:%s@tcp(%s:%d)/%s",
		dbConfig.User,
		dbConfig.Password,
		dbConfig.Address,
		dbConfig.Port,
		dbConfig.DBName)
	if dbConfig.ParseTime {
		url += "?parseTime=true"
	}
	//db, err := sql.Open("mysql", "user:password@tcp(localhost:3306)/test?parseTime=true")
	db, err := sql.Open("mysql", url)
	dbmap := &gorp.DbMap{Db: db, Dialect: gorp.MySQLDialect{"InnoDB", "UTF8"}}
	checkErr(err, "sql.Open failed")
	registerTable(dbmap)
	mysql = dbmap
}
func registerTable(dbmap *gorp.DbMap) {
	//dbmap.AddTableWithName(models.Auth{}, "auth").AddIndex("accountIndex", "Btree", []string{"account"}).SetUnique(true)
	dbmap.AddTableWithName(Post{}, "post").SetKeys(true, "id")
	dbmap.AddTableWithName(Archive{}, "archive").SetKeys(true, "id")
	dbmap.AddTableWithName(Tag{}, "tag").SetKeys(true, "id")
	dbmap.AddTableWithName(Category{}, "category").SetKeys(true, "id")
	dbmap.AddTableWithName(PostHasTag{}, "post_has_tag")
}
func initLoger() {
	slog = logger.Log
}
