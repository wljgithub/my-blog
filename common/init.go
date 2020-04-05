package common

import (
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"log"
	"my-blog/logger"
)

type Configuration struct {
	AppName string

	Server struct {
		Port       int  `yaml:"port"`
		SessionAge int  `yaml:"sessionAge"`
		UseCors    bool `yaml:"useCors"`
		Dist string `yaml:"dist"`
	}
	DB struct {
		DBType    string `yaml:"type"`     //mysql|redis
		Address   string `yaml:"address"`  //localhost
		Port      int    `yaml:"port"`     //3306
		DBName    string `yaml:"name"`     //mydb
		User      string `yaml:"user"`     //account
		Password  string `yaml:"password"` //password
		ParseTime bool   `yaml:"parseTime"`
	}
}

func init() {
	//configPath := path.Join(ProjectRootDir, "conf/config.yml")
	configPath := "./conf/config.yml"
	content, err := ioutil.ReadFile(configPath)
	if err != nil {
		logger.Log.Fatal(err)
	}
	if err := yaml.Unmarshal(content, &Config); err != nil {
		log.Fatal(err)
	}
}

var Config Configuration
