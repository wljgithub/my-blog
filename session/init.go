package session

import (
	"my-blog/common"
	slog "my-blog/logger"
	"sync"
	"time"
)

var Sessions *Session

func init() {
	Sessions = NewSession()
}

type Session struct {
	M      map[string]string
	MaxAge int
	lock   sync.Mutex
}

func NewSession() *Session {
	s := new(Session)
	s.M = make(map[string]string)
	s.MaxAge = common.Config.Server.SessionAge
	s.cleanExpireSession()
	return s
}

func (s *Session) cleanExpireSession() {
	if ok := s.checkSessionInit(); !ok {
		return
	}

	go func() {
		<-time.After(time.Duration(s.MaxAge) * time.Hour)
		s.M = make(map[string]string)

	}()
}
func (s *Session) SetItem(key, value string) {
	if ok := s.checkSessionInit(); !ok {
		return
	}

	s.lock.Lock()
	s.M[key] = value
	s.lock.Unlock()
}
func (s *Session) DeleteItem(key string) bool {
	if ok := s.checkSessionInit(); !ok {
		return false
	}

	s.lock.Lock()
	delete(s.M, key)
	s.lock.Unlock()
	return !s.ItemExist(key)
}
func (s *Session) GetItem(key string) string {
	if ok := s.checkSessionInit(); !ok {
		return ""
	}
	s.lock.Lock()
	defer s.lock.Unlock()
	return s.M[key]

}
func (s *Session) ItemExist(key string) bool {
	if ok := s.checkSessionInit(); !ok {
		return false
	}
	_, ok := s.M[key]
	return ok
}

// checkSessionInit avoid when called by nil pointer
func (s *Session) checkSessionInit() bool {
	if s == nil {
		slog.Log.Error("session hadn't initialized")
		return false
	}
	return true
}
