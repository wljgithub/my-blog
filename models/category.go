package models

import (
	"fmt"
	"my-blog/common"
)

type Category struct {
	Id     int    `db:"id" json:"id"`
	Name   string `db:"name" json:"name"`
	Amount int    `db:"amount" json:"amount"`
}

func AddCategory(category string) (Category, error) {
	err := mysql.Insert(&Category{Name: category})
	if err != nil {
		return Category{}, err
	}
	var c Category
	err = mysql.SelectOne(&c, "SELECT * FROM category ORDER BY ID DESC LIMIT 1")
	return c, err
}
func GetCategory() ([]Category, error) {
	var categories []Category
	_, err := mysql.Select(&categories, "select * from category")
	return categories, err
}

func GetDefaultCategory() int {

	var c Category
	err := mysql.SelectOne(&c, "SELECT * FROM category ORDER BY id LIMIT 1")
	if err != nil || c.Id == 0 {
		c, _ := AddCategory(common.DefaultCategory)
		return c.Id
	}
	return c.Id

}
func LinkCategory(postId, categoryId int) error {
	sql := fmt.Sprintf(
		`UPDATE post SET
		category_id = %d
		where id = %d`,
		categoryId, postId)
	_, err := mysql.Exec(sql)
	return err
}
func GetCategoryIdByPostId(postId int) (int, error) {
	var CategoryId int
	sql := fmt.Sprintf("SELECT category_id from post WHERE id = %d", postId)
	err := mysql.SelectOne(&CategoryId, sql)
	return CategoryId, err
}
func UpdateCategoryAmount(categoryId int) error {
	var sql = fmt.Sprintf("UPDATE category SET amount = amount +1 WHERE id = %d", categoryId)
	_, err := mysql.Exec(sql)
	return err
}
