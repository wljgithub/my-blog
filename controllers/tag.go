package controllers

import (
	"github.com/gin-gonic/gin"
	"github.com/go-sql-driver/mysql"
	"my-blog/models"
	"net/http"
)

type TagReq struct {
	Name string `form:"tag" json:"tag"  binding:"required"`
}
type TagRsp struct {
	Title   string       `json:"title"`
	Content []models.Tag `json:"content"`
}
type AddTagRsp struct {
	BaseResponse
	Tag string `json:"tag"`
}
type LinkTagReq struct {
	PostId int `form:"post_id" json:"post_id" binding:"required"`
	TagId  int `form:"tag_id" json:"tag_id" binding:"required"`
}

func AddTag(c *gin.Context) {

	var tag TagReq

	if err := c.ShouldBind(&tag); err != nil {
		c.JSON(http.StatusBadRequest, BaseResponse{
			Code: 1,
			Msg:  "stag can't be empty",
		})
		return
	}
	if err := models.AddTag(tag.Name); err != nil {
		c.JSON(http.StatusBadRequest, BaseResponse{
			Code: 1,
			Msg:  "failed to add tag",
		})
		return
	}
	c.JSON(http.StatusOK, AddTagRsp{BaseResponse{
		Code: 0,
		Msg:  "succeed to add tag",
	}, tag.Name})
}
func GetTag(c *gin.Context) {
	var tags, err = models.GetTags()
	if err != nil {
		c.JSON(http.StatusBadRequest, BaseResponse{
			Code: 1,
			Msg:  "failed to get tags",
		})
		return
	}
	var rsp = TagRsp{Title: "Tags", Content: tags}
	c.JSON(http.StatusOK, rsp)
}

func LinkTag(c *gin.Context) {

	var linkTag LinkTagReq
	if err := c.ShouldBind(&linkTag); err != nil {
		c.JSON(http.StatusBadRequest, BaseResponse{
			Code: 1,
			Msg:  "postId or tag can't be empty",
		})
		return
	}
	err := models.LinkTag(linkTag.PostId, linkTag.TagId)
	if err != nil {
		if v, ok := err.(*mysql.MySQLError); ok && v.Number == 1062 {
			c.JSON(http.StatusInternalServerError, BaseResponse{
				Code: 1,
				Msg:  "this post had add the tag",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, BaseResponse{
			Code: 1,
			Msg:  "failed to link tag",
		})
		return
	}
	if err := models.AddArticleAmountInTag(linkTag.TagId); err != nil {
		c.JSON(http.StatusOK, BaseResponse{Code: 1, Msg: "failed to add amount to tag"})
		return
	}
	c.JSON(http.StatusOK, BaseResponse{
		Code: 0,
		Msg:  "succeed",
	})
}
