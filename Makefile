# Параметры по умолчанию
DB  ?= greenplum
VER ?= 6
OS  ?= redos7

# Реестры
# BASE_REPO          ?= app-registry01.corp.skbbank.ru/dcms-test/
BASE_REPO          ?= treasuremaster/
# Можно переопределить на зеркало Docker Hub, например: app-registry01.corp.skbbank.ru/dockerhub-proxy/
DOCKERHUB_REGISTRY ?=

# Маппинг ОС -> Базовый образ и фиксированный тег OS_VERSION
ifeq ($(OS),redos7)
    BASE_IMAGE := registry.red-soft.ru/ubi7/ubi
    OS_VERSION ?= 7.3.7-261026
else ifeq ($(OS),oraclelinux8)
    BASE_IMAGE := $(DOCKERHUB_REGISTRY)oraclelinux
    OS_VERSION ?= 8.10
else ifeq ($(OS),ubuntu22)
    BASE_IMAGE := $(DOCKERHUB_REGISTRY)ubuntu
    OS_VERSION ?= 22.04
else ifeq ($(OS),rockylinux9)
    BASE_IMAGE := $(DOCKERHUB_REGISTRY)rockylinux
    OS_VERSION ?= 9.3
else ifeq ($(OS),almalinux9)
    BASE_IMAGE := $(DOCKERHUB_REGISTRY)almalinux
    OS_VERSION ?= 9.3
endif

# Версии СУБД
GPDB_6_VER        ?= 6.27.1
GPDB_7_VER        ?= 7.1.0
GPDB_DUMMY_VER    ?= 0.0.1
GREENGAGE_6_VER   ?= 6.29.2
GREENGAGE_7_VER   ?= 7.4.1
WAREHOUSEPG_6_VER ?= 6.27.2-WHPG

# Выбор версии СУБД, имени итогового образа и директории
ifeq ($(DB),dummy)
    VERSION    := $(GPDB_DUMMY_VER)
    IMAGE_NAME := gp-dummy
    DOCKER_DIR := greenplum/$(OS)/dummy
else ifeq ($(DB),greengage)
    VERSION    := $(GREENGAGE_$(VER)_VER)
    IMAGE_NAME := greengage
    DOCKER_DIR := greengage/$(OS)/$(VER)
else ifeq ($(DB),warehousepg)
    VERSION    := $(WAREHOUSEPG_$(VER)_VER)
    IMAGE_NAME := warehousepg
    DOCKER_DIR := warehousepg/$(OS)/$(VER)
else
    VERSION    := $(GPDB_$(VER)_VER)
    IMAGE_NAME := greenplum
    DOCKER_DIR := greenplum/$(OS)/$(VER)
endif

FULL_TAG := $(BASE_REPO)$(IMAGE_NAME):$(VERSION)-$(OS)

.PHONY: all clean build push test-e2e test-e2e-walg help

all: build

clean:
	@if docker image inspect $(FULL_TAG) >/dev/null 2>&1; then \
		echo "Removing existing image $(FULL_TAG)..."; \
		docker rmi -f $(FULL_TAG); \
	else \
		echo "Image $(FULL_TAG) not found locally, skipping removal."; \
	fi

build: clean
	@echo "Building $(FULL_TAG) using $(BASE_IMAGE):$(OS_VERSION)"
	docker buildx build \
		-f docker/$(DOCKER_DIR)/Dockerfile \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg OS_VERSION=$(OS_VERSION) \
		--build-arg GPDB_VERSION=$(VERSION) \
		-t $(FULL_TAG) .

push:
	docker push $(FULL_TAG)

test-e2e:
	$(MAKE) -C e2e-tests test-e2e

test-e2e-walg:
	$(MAKE) -C e2e-tests test-e2e-walg

help:
	@echo "Примеры запуска:"
	@echo "  make build                                        # greenplum 6 на redos7"
	@echo "  make build OS=oraclelinux8                        # greenplum 6 на oraclelinux8"
	@echo "  make build DB=greengage VER=7 OS=ubuntu22         # greengage 7 на ubuntu22"
	@echo "  make build OS=rockylinux9 OS_VERSION=9.4          # переопределение тега ОС на лету"
	@echo "  make clean [DB=...] [VER=...] [OS=...]            # удалить локальный образ вручную"
