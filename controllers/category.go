package controllers

import (
	"github.com/gin-gonic/gin"
	"my-blog/models"
	"net/http"
)

type Category struct {
	Name string `form:"category" json:"category" binding:"required"`
}
type CategoryRsp struct {
	Title   string            `json:"title"`
	Content []models.Category `json:"content"`
}
type AddCategoryRsp struct {
	BaseResponse
	Category string `json:"category"`
}
type LinkCategoryReq struct {
	CategoryId int `json:"category_id" form:"category_id" binding:"required"`
	PostId     int `json:"post_id" form:"post_id" binding:"required"`
}

func AddCategory(c *gin.Context) {

	var category Category
	if err := c.ShouldBind(&category); err != nil {
		c.JSON(http.StatusBadRequest, BaseResponse{
			Code: 1,
			Msg:  "category can't be empty",
		})
		return
	}
	_, err := models.AddCategory(category.Name)
	if err != nil {
		c.JSON(http.StatusInternalServerError, BaseResponse{
			Code: 1,
			Msg:  "failed to insert into db",
		})
		return
	}
	c.JSON(http.StatusOK, AddCategoryRsp{BaseResponse{
		Code: 0,
		Msg:  "succeed",
	}, category.Name})
}
func GetCategory(c *gin.Context) {
	categories, err := models.GetCategory()
	if err != nil {
		c.JSON(http.StatusInternalServerError, BaseResponse{
			Code: 1,
			Msg:  "failed to query data from db",
		})
		return
	}
	var rsp = CategoryRsp{Title: "Categories", Content: categories}
	c.JSON(http.StatusOK, rsp)
}
func LinkCategory(c *gin.Context) {
	var req LinkCategoryReq
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusOK, BaseResponse{Code: 1, Msg: "required post id or category id"})
		return
	}
	if err := models.LinkCategory(req.PostId, req.CategoryId); err != nil {
		c.JSON(http.StatusOK, BaseResponse{Code: 1, Msg: "db error"})
		return
	}
	c.JSON(http.StatusOK, BaseResponse{Code: 0, Msg: "succeed"})
}
