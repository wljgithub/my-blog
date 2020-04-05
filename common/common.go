package common

import (
	"path"
	"path/filepath"
	"runtime"
)

func init() {
	ProjectRootDir = RootDir()
}

const (
	BlogToken       = "Blog-Token"
	DefaultCategory = "default"
)

var (
	ProjectRootDir string
)

type HttpHeader struct {
	Token string `header:"Blog-Token"`
}

func RootDir() string {
	_, b, _, _ := runtime.Caller(0)
	d := path.Join(path.Dir(b))
	return filepath.Dir(d)
}
