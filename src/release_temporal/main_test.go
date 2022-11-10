package main

import (
	"github.com/stretchr/testify/assert"
	"os"
	"testing"
)

// test the getTags function
func TestGetTags(t *testing.T) {
	assert := assert.New(t)
	tests := map[string]struct {
		tag      string
		expected []string
	}{
		"Version 1": {
			tag:      "0.12.345.6789",
			expected: []string{"0", "0.12", "0.12.345", "0.12.345.6789"},
		},
	}

	for name, tt := range tests {
		t.Run(name, func(t *testing.T) {
			assert.Equal(tt.expected, getTags(tt.tag))
		})
	}
}

// test the loadArgs function
func TestLoadArgs(t *testing.T) {
	assert := assert.New(t)
	tests := map[string]struct {
		args     []string
		expected *Args
	}{
		"Env 1": {
			args: []string{
				"prog",
				"--commit", "7757792ebdff55590a32823c948f1c027d8c3652",
				"--dst-tag", "0.12.345.6789",
				"--images", "image-1 image-2",
				"--username", "foo",
				"--password", "bar",
				"--src-repo", "test-repo",
				"--dst-repo", "release-repo",
				"--set-latest-tag",
			},
			expected: &Args{
				commit:       "7757792ebdff55590a32823c948f1c027d8c3652",
				srcTag:       "sha-7757792",
				dstTags:      []string{"0", "0.12", "0.12.345", "0.12.345.6789"},
				images:       []string{"image-1", "image-2"},
				username:     "foo",
				password:     "bar",
				srcRepo:      "test-repo",
				dstRepo:      "release-repo",
				setLatestTag: true,
			},
		},
	}

	for name, tt := range tests {
		t.Run(name, func(t *testing.T) {
			os.Clearenv()
			initFlags(tt.args)
			assert.Equal(tt.expected, &args)
		})
	}
}
