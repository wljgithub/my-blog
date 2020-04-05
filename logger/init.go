package logger

import (
	"github.com/op/go-logging"
	"os"
)

func init() {
	loger := logging.NewLogBackend(os.Stdout, "", 0)
	formater := logging.NewBackendFormatter(loger, format)
	logging.SetBackend(formater)
}

var format = logging.MustStringFormatter(
	`[%{color}%{time:2006-01-02 15:04:05}] %{longfile} ▶ %{level:.4s} %{color:reset} %{message}`,
)
var Log = logging.MustGetLogger("logger")
