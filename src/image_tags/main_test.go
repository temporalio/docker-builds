package main

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func Test(t *testing.T) {
	assert := assert.New(t)

	getAllTags = func(org, repo string) Tags {
		return Tags{
			Tags: []string{
				"0.0.1",
				"0.0.2",
				"0.2.23",
				"0.2.3",
				"latest",
			},
		}
	}

	latest := getLatestTag("org", "repo")
	assert.Equal("0.2.23", latest)

	bumpPatch := bumpVersion(latest, "patch")
	assert.Equal("0.2.24", bumpPatch)

	bumpMinor := bumpVersion(latest, "minor")
	assert.Equal("0.3.0", bumpMinor)

	bumpMajor := bumpVersion(latest, "major")
	assert.Equal("1.0.0", bumpMajor)
}
