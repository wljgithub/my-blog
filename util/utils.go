package util

import (
	"crypto/md5"
	"fmt"
	"math/rand"
	"strconv"
	"strings"
	"time"
)

// IsNewMonth passed a date like "2020-1", and compare now with it to determine whether add a new month
func IsNewMonth(last, now string) bool {
	l := strings.Split(last, "-")
	n := strings.Split(now, "-")

	if len(l) != 2 || len(n) != 2 {
		return true
	}
	var lArray, nArray = make([]int, 2), make([]int, 2)
	var err error
	for i := 0; i < 2; i++ {
		if lArray[i], err = strconv.Atoi(l[i]); err != nil {
			return true
		}
	}
	if nArray[0] > lArray[0] {
		return true
	}
	if nArray[0] == lArray[0] && nArray[1] > lArray[1] {
		return true
	}
	return false
}

func CopyStructIgnoreEmptyValue(i interface{}) (interface{}, error) {
	// TODO:
	return nil, nil
}
func GenerateToken(account string) string {
	rand.Seed(time.Now().UnixNano())
	random := rand.Intn(10000)
	return GetMd5Hash(account + strconv.Itoa(random))
}
func GetMd5Hash(s string) string {
	return fmt.Sprintf("%x", md5.Sum([]byte(s)))
}
func SplitTokenKey(s string) (string, string) {
	var key, value string
	str := strings.Split(s, "&")
	if len(str) > 1 {
		key, value = str[0], str[1]
	}
	return key, value

}
func GenerateRandomByte(size int) []byte {
	b := make([]byte, size)
	rand.Read(b)
	return b
}
func MD5WithSalt(password string) string {
	var salt = "!@#$%^&*("
	return GetMd5Hash(password + salt)
}
