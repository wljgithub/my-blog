package models

import (
	"fmt"
	"my-blog/util"
	"time"
)

type Archive struct {
	Id     int    `db:"id" json:"id"`
	Name   string `db:"name" json:"name"`
	Amount int    `db:"amount" json:"amount"`
}

func GetArchive() ([]Archive, error) {
	var archives []Archive
	_, err := mysql.Select(&archives, "select * from archive")
	return archives, err
}
func GetArchiveId() int {
	newestArc, err := GetNewestArchive()
	if err != nil || newestArc.Id == 0 || util.IsNewMonth(newestArc.Name, time.Now().Format("2006-01")) {
		if err := InsertArchive(); err != nil {
			slog.Info(err)
		}
		return newestArc.Id + 1
	}
	return newestArc.Id
}
func GetNewestArchive() (Archive, error) {
	var archive Archive
	err := mysql.SelectOne(&archive, "SELECT * FROM archive ORDER BY id DESC LIMIT 1")
	return archive, err
}
func InsertArchive() error {
	var archive = Archive{
		Name: time.Now().Format("2006-01"),
	}
	err := mysql.Insert(&archive)
	return err
}
func AddArchiveCount(id int) error {
	var err error
	var sql = fmt.Sprintf("UPDATE archive SET amount = amount +1 WHERE id = %d", id)
	_, err = mysql.Exec(sql)
	return err
}
