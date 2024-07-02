package main

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

const binFolder = "/usr/local/bin"

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
	updateMajor := os.Getenv("MAJOR") == "true"
	return &Env{
		srcTag:       fmt.Sprintf("sha-%s", commit[0:7]),
		dstTags:      getTags(getEnv("TAG"), updateMajor),
		images:       strings.Split(getEnv("IMAGES"), " "),
		username:     getEnv("USERNAME"),
		password:     getEnv("PASSWORD"),
		srcRepo:      getEnv("SRC_REPO"),
		dstRepo:      getEnv("DST_REPO"),
		setLatestTag: os.Getenv("LATEST") == "true",
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

func getTags(dstTag string, updateMajor bool) []string {
	versions := strings.Split(dstTag, ".")
	vv := versions[0]
	var tags []string
	if updateMajor {
		tags = []string{vv}
	}
	for _, v := range versions[1:] {
		vv += "." + v
		tags = append(tags, vv)
	}
	return tags
}

func mustHaveArchitecture(imageTag, platform, expectedArch string) {
	fmt.Printf("verifying binaries in '%s' from '%s' for platform '%s' are '%s'\n", binFolder, imageTag, platform, expectedArch)

	cmd := exec.Command(
		"docker",
		"run",
		"--platform", platform,
		"--user=root",
		"--rm",
		"--entrypoint=sh",
		imageTag,
		"-c", `
apk add -U file > /dev/null

count=0
for file in `+binFolder+`/*; do
  if [ -f "$file" ]; then
    count=$((count+1))
    if file "$file" | grep -q "`+expectedArch+`"; then
      echo "$file is `+expectedArch+`"
    else
      echo "$file is not `+expectedArch+`"
      file "$file"
      exit 1
    fi
  fi
done

if [ $count -lt 1 ]; then
  echo "no binaries were found"
  exit 1
fi
`)

	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out
	err := cmd.Run()
	fmt.Println(out.String())
	if err != nil {
		log.Fatal(err.Error())
	}
}

func copyImages() {
	env := loadEnv()

	for _, image := range env.images {
		src := fmt.Sprintf("%s/%s:%s", env.srcRepo, image, env.srcTag)
		mustHaveArchitecture(src, "linux/arm64", "ARM")
		mustHaveArchitecture(src, "linux/amd64", "x86")

		srcWithProto := fmt.Sprintf("docker://%s", src)
		destCreds := fmt.Sprintf("--dest-creds=%s:%s", env.username, env.password)
		for _, tag := range env.dstTags {
			dst := fmt.Sprintf("docker://%s/%s:%s", env.dstRepo, image, tag)
			skopeo([]string{"copy", destCreds, "--all", srcWithProto, dst})
		}

		if env.setLatestTag {
			dst_latest := fmt.Sprintf("docker://%s/%s:latest", env.dstRepo, image)
			skopeo([]string{"copy", destCreds, "--all", srcWithProto, dst_latest})
		}
	}
}

func main() {
	copyImages()
}
