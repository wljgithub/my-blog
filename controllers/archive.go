package controllers

import (
	"github.com/gin-gonic/gin"
	"my-blog/models"
	"net/http"
)

type ArchiveRsp struct {
	Title   string           `json:"title"`
	Content []models.Archive `json:"content"`
}

func GetArchive(c *gin.Context) {
	archives, err := models.GetArchive()
	if err != nil {
		c.JSON(http.StatusInternalServerError, BaseResponse{
			Code: 1,
			Msg:  "failed to query data from db",
		})
		return
	}
	var rsp = ArchiveRsp{Title: "Archives", Content: archives}
	c.JSON(http.StatusOK, rsp)
}
