package routers

import (
	"github.com/gin-gonic/gin"
	"my-blog/common"
	"my-blog/controllers"
	"my-blog/util"
	"net/http"
)

func (s *Server) MakeHandler(fn func(*gin.Context), checkPermission bool) gin.HandlerFunc {
	return func(c *gin.Context) {
		if checkPermission {
			if ok := CheckPermission(c, s); !ok {
				return
			}
		}
		fn(c)
	}
}

func CheckPermission(c *gin.Context, s *Server) bool {
	var h = common.HttpHeader{}
	if err := c.ShouldBindHeader(&h); err != nil {
		c.JSON(http.StatusOK, gin.H{"code": 1, "msg": "invalid user"})
		return false
	}

	key, value := util.SplitTokenKey(h.Token)
	if value == "" || s.session.GetItem(key) != value {
		c.JSON(http.StatusOK, gin.H{"code": 1, "msg": "invalid user"})
		return false
	}
	return true
}
func (s *Server) registerRouter() {

	admin := s.router.Group("/api/admin")
	{
		admin.POST("/login", controllers.Login)
		//	need to check permission
		admin.POST("/getSession", s.MakeHandler(controllers.GetToken, true))
		admin.POST("/addTag", s.MakeHandler(controllers.AddTag, true))
		admin.POST("/linkTag", s.MakeHandler(controllers.LinkTag, true))
		admin.POST("/addPost", s.MakeHandler(controllers.AddPost, true))
		admin.POST("/addCategory", s.MakeHandler(controllers.AddCategory, true))
		admin.POST("/logout", s.MakeHandler(controllers.LogOut, true))
		admin.POST("/linkCategory", s.MakeHandler(controllers.LinkCategory, true))
		admin.POST("/verify", s.MakeHandler(controllers.Verify, true))
	}
	common := s.router.Group("/api")
	{
		common.GET("/getTag", controllers.GetTag)
		common.GET("/getCategory", controllers.GetCategory)
		common.GET("/getArchive", controllers.GetArchive)
		common.POST("/getArticleList", controllers.GetArticleList)
		common.GET("/getArticle", controllers.GetArticle)
	}
}
