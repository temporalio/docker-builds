# docker-bake.hcl
variable "platforms" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "IMAGE_REPO" {
  default = "temporaliotest"
}

variable "IMAGE_SHA_TAG" {
  default = null
}

variable "IMAGE_BRANCH_TAG" {
  default = null
}

variable "TEMPORAL_SHA" {
  default = null
}

variable "TCTL_SHA" {
  default = null
}

variable "TAG_LATEST" {
  default = false
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
    "${IMAGE_REPO}/server:${IMAGE_BRANCH_TAG}",
    TAG_LATEST ? "${IMAGE_REPO}/server:latest" : ""
  ]
  platforms = platforms
  args = {
    TEMPORAL_SHA = "${TEMPORAL_SHA}"
    TCTL_SHA = "${TCTL_SHA}"
  }
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
    "${IMAGE_REPO}/admin-tools:${IMAGE_BRANCH_TAG}",
    TAG_LATEST ? "${IMAGE_REPO}/admin-tools:latest" : ""
  ]
  platforms = platforms
  contexts = {
    server = "target:server"
  }
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
    "${IMAGE_REPO}/auto-setup:${IMAGE_BRANCH_TAG}",
    TAG_LATEST ? "${IMAGE_REPO}/auto-setup:latest" : ""
  ]
  platforms = platforms
  contexts = {
    server = "target:server"
    admin-tools = "target:admin-tools"
  }
  labels = {
    "org.opencontainers.image.title" = "auto-setup"
    "org.opencontainers.image.description" = "Workflow as Code (TM) to build and operate resilient applications"
    "org.opencontainers.image.url" = "https://github.com/temporalio/docker-builds"
    "org.opencontainers.image.source" = "https://github.com/temporalio/docker-builds"
    "org.opencontainers.image.licenses" = "MIT"
  }
}
