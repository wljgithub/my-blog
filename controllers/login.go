package controllers

import (
	"github.com/gin-gonic/gin"
	"log"
	"my-blog/common"
	"my-blog/models"
	"my-blog/util"
	"net/http"
)

type BaseResponse struct {
	Code int    `json:"code"`
	Msg  string `json:"msg"`
}
type Token struct {
	Key   string `json:"key" form:"key" binding:"required"`
	Value string `json:"value" form:"value" binding:"required"`
}
type BaseResponseWithToken struct {
	BaseResponse
	Token Token `json:"token"`
}
type LoginReq struct {
	Account  string `form:"account" json:"account" binding:"required"`
	Password string `form:"password" json:"password" binding:"required"`
}

func Login(c *gin.Context) {
	var req LoginReq
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusOK, BaseResponse{
			Code: 1,
			Msg:  "required account and password",
		})
		return
	}

	if err := models.CheckAccount(req.Account, req.Password); err != nil {
		c.JSON(http.StatusOK, BaseResponse{
			Code: 1,
			Msg:  "incorrect account or password",
		})
		return
	}

	token := util.GenerateToken(req.Account)
	sessions.SetItem(req.Account, token)
	t := sessions.GetItem(req.Account)
	log.Println(t)
	c.JSON(http.StatusOK, BaseResponseWithToken{
		BaseResponse{
			Code: 0,
			Msg:  "login Suceess",
		}, Token{Key: req.Account, Value: token},
	})

}
func LogOut(c *gin.Context) {

	var h = common.HttpHeader{}
	if err := c.ShouldBindHeader(&h); err != nil {
		c.JSON(http.StatusOK, BaseResponse{Code: 1, Msg: "invalid header"})
		return
	}
	key, value := util.SplitTokenKey(h.Token)
	if token := sessions.GetItem(key); token == value {
		if ok := sessions.DeleteItem(key); ok {
			c.JSON(http.StatusOK, BaseResponse{Code: 0, Msg: "success"})
			return
		}
	}
	c.JSON(http.StatusOK, BaseResponse{Code: 1, Msg: "failed to clear session"})

}
func Verify(c *gin.Context) {
	c.JSON(http.StatusOK, BaseResponse{Code: 0, Msg: "verify success"})
}
func GetToken(c *gin.Context) {
	s := sessions.GetItem("jack")
	c.JSON(200, gin.H{
		"session": s,
	})
}
