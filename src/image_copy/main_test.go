package main

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetTags(t *testing.T) {
	assert := assert.New(t)
	tests := map[string]struct {
		tag         string
		updateMajor bool
		expected    []string
	}{
		"Version 1": {
			tag:         "0.12.345.6789",
			updateMajor: true,
			expected:    []string{"0", "0.12", "0.12.345", "0.12.345.6789"},
		},
		"Version 2": {
			tag:         "1.23.456.7890",
			updateMajor: false,
			expected:    []string{"1.23", "1.23.456", "1.23.456.7890"},
		},
	}

	for name, tt := range tests {
		t.Run(name, func(t *testing.T) {
			assert.Equal(tt.expected, getTags(tt.tag, tt.updateMajor))
		})
	}
}

func TestLoadEnv(t *testing.T) {
	assert := assert.New(t)
	tests := map[string]struct {
		init     func()
		expected *Env
	}{
		"Env 1": {
			init: func() {
				os.Setenv("COMMIT", "7757792ebdff55590a32823c948f1c027d8c3652")
				os.Setenv("TAG", "0.12.345.6789")
				os.Setenv("IMAGES", "image-1 image-2")
				os.Setenv("USERNAME", "username")
				os.Setenv("PASSWORD", "password")
				os.Setenv("SRC_REPO", "test-repo")
				os.Setenv("DST_REPO", "release-repo")
				os.Setenv("LATEST", "true")
				os.Setenv("MAJOR", "true")
			},
			expected: &Env{
				srcTag:       "sha-7757792",
				dstTags:      []string{"0", "0.12", "0.12.345", "0.12.345.6789"},
				images:       []string{"image-1", "image-2"},
				username:     "username",
				password:     "password",
				srcRepo:      "test-repo",
				dstRepo:      "release-repo",
				setLatestTag: true,
			},
		},
	}

	for name, tt := range tests {
		t.Run(name, func(t *testing.T) {
			os.Clearenv()
			tt.init()
			assert.Equal(tt.expected, loadEnv())
		})
	}
}
