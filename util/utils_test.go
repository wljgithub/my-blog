package util

import "testing"

func TestIsNewMonth(t *testing.T) {
	inputs := []string{"2020-1", "2020-2", "2020-01", "2020-02"}
	for _, v := range inputs {
		if ok := IsNewMonth(v, "2020-2"); ok {
			t.Errorf("test failed")
		}
	}
}
