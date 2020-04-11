package controllers

import (
	"github.com/gin-gonic/gin"
	"my-blog/models"
	"net/http"
	"strconv"
	"time"
)

type Articles struct {
	BaseResponse
	Posts       []models.ArticleList `json:"posts"`
	TotalAmount int                  `json:"total_amount"`
}
type ArticleType struct {
	Category string `json:"category" form:"category" `
	Id       int    `json:"id" form:"id"`
	Offset   int    `json:"offset" form:"offset"`
	Limit    int    `json:"limit" form:"limit"`
}
type EdieArticleRsp struct {
	BaseResponse
	ArticleId int `json:"article_id"`
}

func AddPost(c *gin.Context) {

	var post models.Post
	if err := c.ShouldBind(&post); err != nil {
		c.JSON(http.StatusBadRequest, BaseResponse{
			Code: 1,
			Msg:  "required some filed",
		})
		return
	}
	var articleId int
	// add new post
	if post.Id <= 0 {
		if post.ArchiveId <= 0 {
			post.ArchiveId = models.GetArchiveId()
			models.AddArchiveCount(post.ArchiveId)
		}
		if post.CategoryId <= 0 {
			post.CategoryId = models.GetDefaultCategory()
		}
		//post.CreatedTime = time.Now()
		post.UpdatedTime = time.Now()
		// assign to default category if post without category

		if err := models.AddPost(post); err != nil {
			c.JSON(http.StatusBadRequest, BaseResponse{
				Code: 1,
				Msg:  "failed to add post",
			})
			return
		}
		articleId, _ = models.GetNewstArticleId()

		// edit existing post
	} else {
		post.UpdatedTime = time.Now()
		if err := models.UpdatePost(post); err != nil {
			c.JSON(http.StatusInternalServerError, BaseResponse{
				Code: 1,
				Msg:  "failed to updated post",
			})
			return
		}
		articleId = post.Id
	}
	c.JSON(http.StatusOK, EdieArticleRsp{BaseResponse{
		Code: 0,
		Msg:  "succeed",
	}, articleId})
}

func GetArticle(c *gin.Context) {
	id, err := strconv.Atoi(c.Query("id"))
	if id > 0 && err == nil {
		article, err := models.GetArticleById(id)
		if err != nil {
			c.JSON(http.StatusOK, BaseResponse{Code: 1, Msg: "db error"})
			return
		}
		if err := models.AddViewCount(id); err != nil {
			c.JSON(http.StatusOK, BaseResponse{Code: 1, Msg: "failed to add view count"})
			return
		}
		c.JSON(http.StatusOK, article)
		return
	}
	c.JSON(http.StatusOK, BaseResponse{Code: 1, Msg: "invalid id"})
}
func GetArticleList(c *gin.Context) {
	var articleType ArticleType
	if err := c.ShouldBind(&articleType); err != nil {
		c.JSON(http.StatusBadRequest, BaseResponse{
			Code: 1,
			Msg:  "category can't be empty",
		})
		return
	}
	var articleList []models.ArticleList
	var totalArticleAmount int
	var err error

	if articleType.Category == "recommend" {
		totalArticleAmount, err = models.GetRecommendArticleAmount()
		articleList, err = models.GetRecommendArticleList(articleType.Offset, articleType.Limit)
	} else if articleType.Category == "tag" && articleType.Id > 0 {
		totalArticleAmount, _ = models.GetArticleAmountByTag(articleType.Id)
		articleList, err = models.GetArticleListByTag(articleType.Id, articleType.Offset, articleType.Limit)
	} else if articleType.Category == "category" && articleType.Id > 0 {
		totalArticleAmount, _ = models.GetArticleAmountByCategory(articleType.Id)
		articleList, err = models.GetArticleListByCategory(articleType.Id, articleType.Offset, articleType.Limit)
	} else if articleType.Category == "archive" && articleType.Id > 0 {
		totalArticleAmount, _ = models.GetArticleAmountByArchive(articleType.Id)
		articleList, err = models.GetArticleListByArchive(articleType.Id, articleType.Offset, articleType.Limit)
	} else {
		totalArticleAmount, _ = models.GetDefaultArticleAmount()
		articleList, err = models.GetDefaultArticleList(articleType.Offset, articleType.Limit)
	}
	if err != nil {
		c.JSON(http.StatusOK, BaseResponse{Code: 1, Msg: "db error"})
		return
	}

	c.JSON(http.StatusOK, Articles{BaseResponse{Code: 0, Msg: "success"}, articleList, totalArticleAmount})
}
