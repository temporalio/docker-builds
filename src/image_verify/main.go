package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

const binFolder = "/usr/local/bin"

type Env struct {
	images  []string
	srcRepo string
	srcTag  string
	arch    string
}

func loadEnv() *Env {
	commit := getEnv("COMMIT")
	return &Env{
		images:  strings.Split(getEnv("IMAGES"), " "),
		srcRepo: getEnv("SRC_REPO"),
		srcTag:  fmt.Sprintf("sha-%s", commit[0:7]),
		arch:    getEnv("ARCH"),
	}
}

func getEnv(key string) string {
	val, ok := os.LookupEnv(key)
	if !ok {
		log.Fatalf("Required env %q not set\n", key)
	}
	return val
}

func mustHaveArchitecture(imageTag, expectedArch string) {
	fmt.Printf("verifying binaries in '%s' from '%s' are '%s'\n", binFolder, imageTag, expectedArch)

	cmd := exec.Command(
		"docker",
		"run",
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
	out, err := cmd.CombinedOutput()
	fmt.Println(string(out))
	if err != nil {
		log.Fatal(err.Error())
	}
}

func verifyImages() {
	env := loadEnv()

	for _, image := range env.images {
		src := fmt.Sprintf("%s/%s:%s", env.srcRepo, image, env.srcTag)
		mustHaveArchitecture(src, env.arch)
	}
}

func main() {
	verifyImages()
}
