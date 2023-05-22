package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"sort"

	semver "github.com/Masterminds/semver/v3"
)

type (
	TokenOutput struct {
		Token string `json:"token"`
	}

	Tags struct {
		Name string   `json:"name"`
		Tags []string `json:"tags"`
	}
)

// getToken returns the token for the repository
func getToken(org, repo string) string {
	tokenURL := fmt.Sprintf("https://auth.docker.io/token?service=registry.docker.io&scope=repository:%s/%s:pull", org, repo)
	resp, err := http.Get(tokenURL)
	if err != nil {
		log.Fatal(err.Error())
	}
	defer resp.Body.Close()

	tokenJSON, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err.Error())
	}

	var out TokenOutput
	err = json.Unmarshal(tokenJSON, &out)
	if err != nil {
		log.Fatal(err.Error())
	}
	return out.Token
}

// getLatestTag returns all tags for the repository
func getAllTags(org, repo string) Tags {
	tagsListURL := fmt.Sprintf("https://registry.hub.docker.com/v2/%s/%s/tags/list", org, repo)
	req, err := http.NewRequest("GET", tagsListURL, nil)
	if err != nil {
		log.Fatal(err.Error())
	}
	token := getToken(org, repo)
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Fatal(err.Error())
	}
	defer resp.Body.Close()

	tagsJSON, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err.Error())
	}

	var tags Tags
	err = json.Unmarshal(tagsJSON, &tags)
	if err != nil {
		log.Fatal(err.Error())
	}
	return tags
}

// getLatestTag returns the latest tag for a repo
func getLatestTag(org, repo string) string {
	tags := getAllTags(org, repo)
	vs := make([]*semver.Version, len(tags.Tags))
	for i, r := range tags.Tags {
		v, err := semver.NewVersion(r)
		if err != nil {
			log.Fatalf("Error parsing version: %s", err)
		}

		vs[i] = v
	}

	sort.Sort(semver.Collection(vs))
	latest := vs[len(vs)-1]
	return latest.String()
}

// bumpVersion bumps the latest tag for a repo
func bumpVersion(version, bump string) string {
	v, err := semver.NewVersion(version)
	if err != nil {
		log.Fatalf("Error parsing version: %s", err)
	}
	var newVersion semver.Version
	switch bump {
	case "major":
		newVersion = v.IncMajor()
	case "minor":
		newVersion = v.IncMinor()
	case "patch":
		newVersion = v.IncPatch()
	default:
		log.Fatalf("Unknown bump type %q\n", bump)
	}
	return newVersion.String()
}

func main() {
	org := flag.String("org", "temporalio", "Docker organization")
	repo := flag.String("repo", "", "Docker repository")
	help := flag.Bool("help", false, "Show usage")
	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), "Usage of %s:\n", os.Args[0])
		fmt.Println("Options:")
		flag.PrintDefaults()
		fmt.Println("Commands:")
		fmt.Println("  all     - return all tags for a repo")
		fmt.Println("  latest  - return only the most latest tag for a repo")
		fmt.Println("  bump    - bump the latest tag for a repo")
		fmt.Println("    major - bump major version")
		fmt.Println("    minor - bump minor version")
		fmt.Println("    patch - bump patch version")
	}
	flag.Parse()

	if *help || len(flag.Args()) < 1 || len(*org) == 0 || len(*repo) == 0 {
		flag.Usage()
		os.Exit(0)
	}

	cmd := flag.Arg(0)

	switch cmd {
	case "all":
		tags := getAllTags(*org, *repo)
		json, err := json.Marshal(tags)
		if err != nil {
			log.Fatal(err.Error())
		}
		fmt.Println(string(json))
	case "latest":
		fmt.Println(getLatestTag(*org, *repo))
	case "bump":
		latest := getLatestTag(*org, *repo)
		if len(flag.Args()) < 2 {
			flag.Usage()
			log.Fatal("Missing bump type")
		}
		fmt.Println(bumpVersion(latest, flag.Arg(1)))
	default:
		log.Fatalf("Unknown command %q\n", cmd)
	}
}
