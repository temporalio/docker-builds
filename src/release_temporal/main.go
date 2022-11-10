package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

// program arguments
type Args struct {
	commit       string
	srcTag       string
	dstTags      []string
	images       []string
	username     string
	password     string
	srcRepo      string
	dstRepo      string
	setLatestTag bool
}

var args Args

// function to parse tags from version
// if version is 1.2.3 then tags will be 1.2.3, 1.2, 1
func getTags(version string) []string {
	versions := strings.Split(version, ".")
	vv := versions[0]
	tags := []string{vv}
	for _, v := range versions[1:] {
		vv += "." + v
		tags = append(tags, vv)
	}
	return tags
}

// init function to load command line flags
// and check if all required arguments are provided
func initFlags(osArgs []string) {
	var images, tag string

	flagSet := flag.NewFlagSet(osArgs[0], flag.ExitOnError)

	flagSet.StringVar(&args.commit, "commit", os.Getenv("COMMIT"), "Commit hash")
	flagSet.StringVar(&args.srcTag, "src-tag", os.Getenv("SRC_TAG"), "Source tag")
	flagSet.StringVar(&tag, "dst-tag", os.Getenv("DST_TAG"), "Destination tags")
	flagSet.StringVar(&images, "images", os.Getenv("IMAGES"), "Images")
	flagSet.StringVar(&args.username, "username", os.Getenv("USERNAME"), "Docker registry username")
	flagSet.StringVar(&args.password, "password", os.Getenv("PASSWORD"), "Docker registry password")
	flagSet.StringVar(&args.srcRepo, "src-repo", os.Getenv("SRC_REPO"), "Source repository")
	flagSet.StringVar(&args.dstRepo, "dst-repo", os.Getenv("DST_REPO"), "Destination repository")
	flagSet.BoolVar(&args.setLatestTag, "set-latest-tag", os.Getenv("LATEST") != "", "Set latest tag")
	flagSet.Parse(osArgs[1:])

	args.dstTags = getTags(tag)
	if images != "" {
		args.images = strings.Split(images, " ")
	}
	if args.srcTag == "" && len(args.commit) > 7 {
		args.srcTag = fmt.Sprintf("sha-%s", args.commit[0:7])
	}

	// check if all required arguments are provided
	if args.commit == "" {
		log.Fatal("Commit hash not set")
	}
	if args.srcTag == "" {
		log.Fatal("Source tag not set")
	}
	if len(args.dstTags) == 0 {
		log.Fatal("Destination tags not set")
	}
	if len(args.images) == 0 {
		log.Fatal("Images not set")
	}
	if args.username == "" {
		log.Fatal("Username not set")
	}
	if args.password == "" {
		log.Fatal("Password not set")
	}
	if args.srcRepo == "" {
		log.Fatal("Source repository not set")
	}
	if args.dstRepo == "" {
		log.Fatal("Destination repository not set")
	}
}

// function to run skopeo command
func skopeo(arguments []string) {
	params := []string{"run", "--rm", "-i", "quay.io/skopeo/stable"}
	params = append(params, arguments...)
	cmd := exec.Command("docker", params...)
	stdout, err := cmd.CombinedOutput()
	log.Println(string(stdout))
	if err != nil {
		log.Fatal(err.Error())
	}
}

// function to copy images from source repository to destination repository
func copyImages() {
	for _, image := range args.images {
		src := fmt.Sprintf("docker://%s/%s:%s", args.srcRepo, image, args.srcTag)
		destCreds := fmt.Sprintf("--dest-creds=%s:%s", args.username, args.password)

		for _, tag := range args.dstTags {
			dst := fmt.Sprintf("docker://%s/%s:%s", args.dstRepo, image, tag)
			skopeo([]string{"copy", destCreds, "--all", src, dst})
		}

		if args.setLatestTag {
			dst_latest := fmt.Sprintf("docker://%s/%s:latest", args.dstRepo, image)
			skopeo([]string{"copy", destCreds, "--all", src, dst_latest})
		}
	}
}

func main() {
	initFlags(os.Args)
	copyImages()
}
