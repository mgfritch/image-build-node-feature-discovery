SEVERITIES = HIGH,CRITICAL

UNAME_M = $(shell uname -m)
ARCH=
ifeq ($(UNAME_M), x86_64)
        ARCH=amd64
else ifeq ($(UNAME_M), aarch64)
        ARCH=arm64
else
        ARCH=$(UNAME_M)
endif

BUILD_META=-build$(shell date +%Y%m%d)
ORG ?= rancher
PKG ?= "github.com/kubernetes-sigs/node-feature-discovery"
SRC ?= "github.com/kubernetes-sigs/node-feature-discovery"
TAG ?= ${GITHUB_ACTION_TAG}

ifeq ($(TAG),)
TAG := v0.15.6$(BUILD_META)
endif

ifeq (,$(filter %$(BUILD_META),$(TAG)))
$(error TAG needs to end with build metadata: $(BUILD_META))
endif

.PHONY: image-build
image-build:
	docker buildx build \
		--pull \
		--platform=$(ARCH) \
		--build-arg ARCH=$(ARCH) \
		--build-arg PKG=$(PKG) \
		--build-arg SRC=$(SRC) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
		--tag $(ORG)/hardened-node-feature-discovery:$(TAG) \
		--tag $(ORG)/hardened-node-feature-discovery:$(TAG)-$(ARCH) \
		--load \
		.

.PHONY: image-push
image-push:
	docker push $(ORG)/hardened-node-feature-discovery:$(TAG)-$(ARCH)

.PHONY: image-scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed image $(ORG)/hardened-node-feature-discovery:$(TAG)

.PHONY: log
log:
	@echo "ARCH=$(ARCH)"
	@echo "TAG=$(TAG:$(BUILD_META)=)"
	@echo "ORG=$(ORG)"
	@echo "PKG=$(PKG)"
	@echo "SRC=$(SRC)"
	@echo "BUILD_META=$(BUILD_META)"
	@echo "UNAME_M=$(UNAME_M)"
