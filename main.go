package main

import (
	"my-blog/common"
	"my-blog/routers"
	"strconv"
)

func main() {
	var port = ":" + strconv.Itoa(common.Config.Server.Port)
	server := routers.NewServer()
	server.Run(port)
}
