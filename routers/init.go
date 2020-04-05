package routers

import (
	"fmt"
	"github.com/gin-contrib/cors"
	"github.com/gin-contrib/static"
	"github.com/gin-gonic/gin"
	"my-blog/common"
	"my-blog/session"
	"time"
)

type Server struct {
	router  *gin.Engine
	session *session.Session
}

func NewServer() *Server {
	server := new(Server)
	server.router = gin.New()
	server.init()
	return server
}
func (s *Server) init() {
	gin.ForceConsoleColor()
	s.UseMiddleWare()
	s.enableSession()
	s.registerRouter()
	s.ServerStaticFile()
}

func (s *Server) Run(addr ...string) error {
	return s.router.Run(addr...)
}
func (s *Server) ServerStaticFile() {
	//s.router.Static("/", "./blog-admin/dist")
	//s.router.StaticFS("/more_static", http.Dir("my_file_system"))
	//s.router.StaticFile("/favicon.ico", "./resources/favicon.ico")
}
func (s *Server) UseMiddleWare() {

	if common.Config.Server.UseCors {
		s.router.Use(cors.Default())
	}
	s.router.Use(gin.Recovery())
	s.router.Use(gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		var statusColor, resetColor, methodColor string

		statusColor = param.StatusCodeColor()
		resetColor = param.ResetColor()
		methodColor = param.MethodColor()
		return fmt.Sprintf("%s - [%s] \"%s %s %s %s %s %s %d %s %s \"%s\" %s\"\n",
			param.ClientIP,
			param.TimeStamp.Format(time.RFC1123),
			methodColor, param.Method, resetColor,
			param.Path,
			param.Request.Proto,
			statusColor, param.StatusCode, resetColor,
			param.Latency,
			param.Request.UserAgent(),
			param.ErrorMessage,
		)
	}))
	s.router.Use(static.Serve("/", static.LocalFile(common.Config.Server.Dist, false)))
}
func (s *Server) enableSession() {
	s.session = session.Sessions
}
