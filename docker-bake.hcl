# docker-bake.hcl
variable "platforms" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "IMAGE_TAG" {
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
  tags = [
    "temporaliotest/server:${IMAGE_TAG}",
    TAG_LATEST ? "temporaliotest/server:latest" : ""
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
    "temporaliotest/admin-tools:${IMAGE_TAG}",
    TAG_LATEST ? "temporaliotest/admin-tools:latest" : ""
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
  dockerfile = "auto-setup.Dockerfile"
  tags = [
    "temporaliotest/auto-setup:${IMAGE_TAG}",
    TAG_LATEST ? "temporaliotest/auto-setup:latest" : ""
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
