package models

import "errors"

type Auth struct {
	UId      int64  `db:"uid,primarykey,autoincrement"`
	Created  string `db:"created_time,size:50,notnull"`
	Account  string `db:"account,size:50,notnull"`
	Password string `db:"password,size:50,notnull"`
	Email    string `db:"-"`
}

func CheckAccount(account, password string) error {
	var auth Auth
	err := mysql.SelectOne(&auth, "select * from auth where account = ?", account)
	checkErr(err, "failed to query password")

	if auth.Account == account && auth.Password == password {
		return nil
	}
	return errors.New("incorrect account or password")
}
