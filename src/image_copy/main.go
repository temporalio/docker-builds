package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/google/uuid"
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

func execCmd(name string, args ...string) string {
	cmd := exec.Command(name, args...)
	fmt.Println("\n> ", name, strings.Join(args, " "))
	out, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println(string(out))
		log.Fatal(err.Error())
	}
	return string(out)
}

func mustHaveArchitecture(imageTag, platform, expectedArch string) {
	fmt.Printf("\nverifying binaries in %q from %q for platform %q are %q\n", binFolder, imageTag, platform, expectedArch)

	// create local container from image
	containerId := uuid.NewString()
	out := execCmd(
		"docker",
		"create",
		"--name", containerId,
		"--platform", platform,
		imageTag)
	fmt.Println(out)
	defer execCmd("docker", "rm", containerId)

	// copy binaries to local tmp dir
	tmpDir, err := os.MkdirTemp(os.TempDir(), containerId)
	if err != nil {
		log.Fatal(err)
	}
	defer os.RemoveAll(tmpDir)
	out = execCmd(
		"docker",
		"cp",
		containerId+":"+binFolder+"/.",
		tmpDir)
	fmt.Println(out)

	// verify binaries
	files, err := os.ReadDir(tmpDir)
	if err != nil {
		log.Fatal(err.Error())
	}
	if len(files) == 0 {
		log.Fatal("no binaries were found")
	}
	for _, file := range files {
		fp := filepath.Join(tmpDir, file.Name())
		info, err := os.Lstat(fp)
		if err != nil {
			log.Fatal(err.Error())
		}
		if info.Mode()&os.ModeSymlink != 0 {
			// skip symlinks
			continue
		}
		out = execCmd("file", fp)
		if !strings.Contains(out, expectedArch) {
			log.Fatal(file.Name() + " is NOT " + expectedArch)
		} else {
			fmt.Println(file.Name() + " is " + expectedArch)
		}
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
