# docker-bake.hcl
variable "platforms" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "IMAGE_REPO" {
  default = "temporaliotest"
}

variable "IMAGE_SHA_TAG" {}

variable "IMAGE_BRANCH_TAG" {}

variable "SAFE_IMAGE_BRANCH_TAG" {
  default = join("-", [for c in regexall("[a-z0-9]+", lower(IMAGE_BRANCH_TAG)) : c])
}

variable "TEMPORAL_SHA" {}

variable "TCTL_SHA" {}

variable "TAG_LATEST" {
  default = false
}

variable "DOCKER_BUILDX_CACHE_FROM" {
  default = "type=gha"
}

variable "DOCKER_BUILDX_CACHE_TO" {
  default = "type=gha,mode=max"
}

group "default" {
  targets = [
    "server",
    "admin-tools",
    "auto-setup",
  ]
}

target "server" {
  dockerfile = "server.Dockerfile"
  target = "server"
  tags = [
    "${IMAGE_REPO}/server:${IMAGE_SHA_TAG}",
    "${IMAGE_REPO}/server:${SAFE_IMAGE_BRANCH_TAG}",
    TAG_LATEST ? "${IMAGE_REPO}/server:latest" : ""
  ]
  platforms = platforms
  args = {
    TEMPORAL_SHA = "${TEMPORAL_SHA}"
    TCTL_SHA = "${TCTL_SHA}"
  }
  cache-from = [DOCKER_BUILDX_CACHE_FROM != "" ? "${DOCKER_BUILDX_CACHE_FROM},scope=server" : "type=gha,scope=server"]
  cache-to = [DOCKER_BUILDX_CACHE_TO != "" ? "${DOCKER_BUILDX_CACHE_TO},scope=server" : "type=gha,mode=max,scope=server"]
  labels = {
    "org.opencontainers.image.title" = "server"
    "org.opencontainers.image.description" = "Workflow as Code (TM) to build and operate resilient applications"
    "org.opencontainers.image.url" = "https://github.com/temporalio/temporal"
    "org.opencontainers.image.source" = "https://github.com/temporalio/temporal"
    "org.opencontainers.image.licenses" = "MIT"
  }
}

target "admin-tools" {
  dockerfile = "admin-tools.Dockerfile"
  tags = [
    "${IMAGE_REPO}/admin-tools:${IMAGE_SHA_TAG}",
    "${IMAGE_REPO}/admin-tools:${SAFE_IMAGE_BRANCH_TAG}",
    TAG_LATEST ? "${IMAGE_REPO}/admin-tools:latest" : ""
  ]
  platforms = platforms
  contexts = {
    server = "target:server"
  }
  cache-from = [DOCKER_BUILDX_CACHE_FROM != "" ? "${DOCKER_BUILDX_CACHE_FROM},scope=admin-tools" : "type=gha,scope=admin-tools"]
  cache-to = [DOCKER_BUILDX_CACHE_TO != "" ? "${DOCKER_BUILDX_CACHE_TO},scope=admin-tools" : "type=gha,mode=max,scope=admin-tools"]
  labels = {
    "org.opencontainers.image.title" = "admin-tools"
    "org.opencontainers.image.description" = "Workflow as Code (TM) to build and operate resilient applications"
    "org.opencontainers.image.url" = "https://github.com/temporalio/docker-builds"
    "org.opencontainers.image.source" = "https://github.com/temporalio/docker-builds"
    "org.opencontainers.image.licenses" = "MIT"
  }
}

target "auto-setup" {
  dockerfile = "server.Dockerfile"
  target = "auto-setup"
  tags = [
    "${IMAGE_REPO}/auto-setup:${IMAGE_SHA_TAG}",
    "${IMAGE_REPO}/auto-setup:${SAFE_IMAGE_BRANCH_TAG}",
    TAG_LATEST ? "${IMAGE_REPO}/auto-setup:latest" : ""
  ]
  platforms = platforms
  contexts = {
    server = "target:server"
    admin-tools = "target:admin-tools"
  }
  cache-from = [DOCKER_BUILDX_CACHE_FROM != "" ? "${DOCKER_BUILDX_CACHE_FROM},scope=auto-setup" : "type=gha,scope=auto-setup"]
  cache-to = [DOCKER_BUILDX_CACHE_TO != "" ? "${DOCKER_BUILDX_CACHE_TO},scope=auto-setup" : "type=gha,mode=max,scope=auto-setup"]
  labels = {
    "org.opencontainers.image.title" = "auto-setup"
    "org.opencontainers.image.description" = "Workflow as Code (TM) to build and operate resilient applications"
    "org.opencontainers.image.url" = "https://github.com/temporalio/docker-builds"
    "org.opencontainers.image.source" = "https://github.com/temporalio/docker-builds"
    "org.opencontainers.image.licenses" = "MIT"
  }
}
