package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

type Env struct {
	srcTag       string
	dstTags      []string
	images       []string
	username     string
	password     string
	srcRepo      string
	dstRepo      string
	setLatestTag bool
}

func loadEnv() *Env {
	commit := getEnv("COMMIT")
	return &Env{
		srcTag:       fmt.Sprintf("sha-%s", commit[0:7]),
		dstTags:      getTags(getEnv("TAG")),
		images:       strings.Split(getEnv("IMAGES"), " "),
		username:     getEnv("USERNAME"),
		password:     getEnv("PASSWORD"),
		srcRepo:      getEnv("SRC_REPO"),
		dstRepo:      getEnv("DST_REPO"),
		setLatestTag: os.Getenv("LATEST") != "",
	}
}

func getEnv(key string) string {
	val, ok := os.LookupEnv(key)
	if !ok {
		log.Fatalf("Required env %q not set\n", key)
	}
	return val
}

func skopeo(arguments []string) {
	args := []string{"run", "--rm", "-i", "quay.io/skopeo/stable"}
	args = append(args, arguments...)
	cmd := exec.Command("docker", args...)
	stdout, err := cmd.CombinedOutput()
	log.Println(string(stdout))
	if err != nil {
		log.Fatal(err.Error())
	}
}

func getTags(dstTag string) []string {
	versions := strings.Split(dstTag, ".")
	vv := versions[0]
	tags := []string{vv}
	for _, v := range versions[1:] {
		vv += "." + v
		tags = append(tags, vv)
	}
	return tags
}

func copyImages() {
	env := loadEnv()

	for _, image := range env.images {
		src := fmt.Sprintf("docker://%s/%s:%s", env.srcRepo, image, env.srcTag)
		destCreds := fmt.Sprintf("--dest-creds=%s:%s", env.username, env.password)

		for _, tag := range env.dstTags {
			dst := fmt.Sprintf("docker://%s/%s:%s", env.dstRepo, image, tag)
			skopeo([]string{"copy", destCreds, "--all", src, dst})
		}

		if env.setLatestTag {
			dst_latest := fmt.Sprintf("docker://%s/%s:latest", env.dstRepo, image)
			skopeo([]string{"copy", destCreds, "--all", src, dst_latest})
		}
	}
}

func main() {
	copyImages()
}
