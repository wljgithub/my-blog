package models

import "fmt"

type Tag struct {
	Id     int    `db:"id" json:"id"`
	Name   string `db:"name" json:"name"`
	Amount int    `db:"amount" json:"amount"`
}
type PostHasTag struct {
	PostId int `db:"post_id"`
	TagId  int `db:"tag_id"`
}

func AddTag(name string) error {
	err := mysql.Insert(&Tag{Name: name})
	return err
}
func GetTags() ([]Tag, error) {
	var tags []Tag
	_, err := mysql.Select(&tags, "select * from tag")
	return tags, err
}

func LinkTag(postId, tagId int) error {
	var linkTag = PostHasTag{PostId: postId, TagId: tagId}
	err := mysql.Insert(&linkTag)
	return err
}
func AddArticleAmountInTag(tagId int) error {
	var sql = fmt.Sprintf("UPDATE tag SET amount = amount + 1 WHERE id = %d", tagId)
	_, err := mysql.Exec(sql)
	return err
}
