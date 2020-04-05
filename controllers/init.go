package controllers

import "my-blog/session"

var sessions *session.Session

func init() {
	sessions = session.Sessions
}
