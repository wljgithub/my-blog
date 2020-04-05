package models

import (
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"log"
	"time"
)

type Post struct {
	Id          int       `db:"id" form:"id" json:"id"`
	Title       string    `db:"title" json:"title" form:"title" binding:"required"`
	Content     string    `db:"content" json:"content" form:"content"`
	UpdatedTime time.Time `db:"updated_time" json:"-"`
	View        int       `db:"view" json:"view"`
	Author      string    `db:"author" json:"author"`
	SaveType    int       `db:"save_type" form:"save_type" json:"save_type" `
	ArchiveId   int       `db:"archive_id" form:"archive_id" json:"archive_id"`
	CategoryId  int       `db:"category_id" form:"category_id" json:"category_id"`
}
type PostWithCreatedTime struct {
	Post
	CreatedTime time.Time `db:"created_time" json:"created_time"`
}
type PostWithTagName struct {
	Post Post
	Name string `db:"name"`
}
type ArticleList struct {
	Id      int    `json:"id" db:"id"`
	Title   string `json:"title" db:"title"`
	Content string `json:"content" db:"content"`
	View    int    `json:"view" db:"view"`
	Author  string `json:"author" db:"author"`
	Date    string `json:"date" db:"created_time"`
}

func checkErr(err error, msg string) {
	if err != nil {
		log.Println(msg, err)
	}
}

func GetNewstArticleId() (int, error) {
	var id int
	err := mysql.SelectOne(&id, "SELECT id FROM post ORDER BY id DESC limit 1")
	return id, err

}
func AddViewCount(id int) error {
	_, err := mysql.Exec(fmt.Sprintf("UPDATE post SET view = view + 1 WHERE id = %d", id))
	return err

}
func AddPost(post Post) error {
	err := mysql.Insert(&post)
	return err
}

func UpdatePost(post Post) error {
	_, err := mysql.Update(&post)
	return err
}
func GetArticleById(id int) (PostWithCreatedTime, error) {
	var article PostWithCreatedTime
	var sql = fmt.Sprintf("SELECT * FROM post WHERE id = %d", id)
	err := mysql.SelectOne(&article, sql)
	return article, err
}
func GetDefaultArticleList(offset, limit int) ([]ArticleList, error) {
	var sql = "SELECT id,title,SUBSTR(content,1,200) as content,view,author,created_time FROM post ORDER BY id DESC"
	return getArticleListByOffSet(sql, offset, limit)
}
func GetRecommendArticleList(offset, limit int) ([]ArticleList, error) {
	var sql = "SELECT id,title,SUBSTRING(content,1,200) as content,view,author,created_time FROM post "
	return getArticleListByOffSet(sql, offset, limit)
}
func GetArticleListByTag(id int, offset, limit int) ([]ArticleList, error) {
	var sql = fmt.Sprintf(`SELECT id,title,SUBSTRING(content,1,200) as content,view,author,created_time from blog.post as p, blog.post_has_tag as b WHERE p.id=b.post_id AND b.tag_id = %d`, id)
	return getArticleListByOffSet(sql, offset, limit)
}
func GetArticleListByArchive(id int, offset, limit int) ([]ArticleList, error) {
	return getArticleList("archive_id", id, offset, limit)
}
func GetArticleListByCategory(id int, offset, limit int) ([]ArticleList, error) {
	return getArticleList("category_id", id, offset, limit)
}
func GetRecommendArticleAmount() (int, error) {
	return getAllTotalArticleAmount()
}
func GetDefaultArticleAmount() (int, error) {
	return getAllTotalArticleAmount()
}
func getAllTotalArticleAmount() (int, error) {
	var amount int
	var sql = "SELECT COUNT(*) FROM post"
	err := mysql.SelectOne(&amount, sql)
	return amount, err
}
func GetArticleAmountByTag(tagId int) (int, error) {
	var amount int
	sql := fmt.Sprintf("SELECT COUNT(*) FROM post_has_tag WHERE tag_id = %d", tagId)
	err := mysql.SelectOne(&amount, sql)
	return amount, err
}
func GetArticleAmountByCategory(catgoryId int) (int, error) {
	return getArticleAmountBy("category_id", catgoryId)
}
func GetArticleAmountByArchive(archiveId int) (int, error) {
	return getArticleAmountBy("archive_id", archiveId)
}

func getArticleAmountBy(name string, id int) (int, error) {
	var amount int
	sql := fmt.Sprintf("SELECT COUNT(*) FROM post WHERE %s = %d", name, id)
	err := mysql.SelectOne(&amount, sql)
	return amount, err

}
func getArticleList(_type string, id int, offset, limit int) ([]ArticleList, error) {

	var sql = fmt.Sprintf("SELECT id,title,SUBSTRING(content,1,200) as content,view,author,created_time FROM post Where %s = %d", _type, id)
	return getArticleListByOffSet(sql, offset, limit)
}
func getArticleListByOffSet(sql string, offset, limit int) ([]ArticleList, error) {
	var articleList []ArticleList
	sql = fmt.Sprintf("%s LIMIT %d OFFSET %d ", sql, limit, offset)
	_, err := mysql.Select(&articleList, sql)
	return articleList, err
}
