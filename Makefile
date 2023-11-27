checkleak:
	docker run -v /home/annd2/Documents/vdb/opentelemetry-collector-contrib-release:/path zricethezav/gitleaks:latest detect --source="/path" --no-git -v

bench:
	sysbench oltp_read_only --mysql-host=61.28.226.201 --mysql-user=annd2 --mysql-password=password --mysql-port=3306 --mysql-db=hihi --threads=120 --tables=40 --table-size=200000 --range_selects=off --db-ps-mode=disable --report-interval=1 --time=6000 run
profile:
	# go tool pprof http://localhost:6060/debug/pprof/heap
	# go tool pprof http://localhost:6060/debug/pprof/goroutine
	go tool pprof http://localhost:7070/debug/pprof/profile?seconds=600
	# go tool pprof http://localhost:6060/debug/pprof/block
	# go tool pprof http://localhost:6060/debug/pprof/mutex
	# go tool pprof http://localhost:6060/debug/pprof/trace?seconds=20


    # CPU: profile?seconds=10
    # Memory: heap
    # Goroutines: goroutine
    # Goroutine blocking: block
    # Locks: mutex
    # Tracing: trace?seconds=5

test-install:
	V_USER=annd2 V_PASS=password V_HOST=localhost V_PORT=3306 bash install-local.sh

buildd:
	rm -rf build
	NIGHTLY=vmonitor make package include_packages="amd64.deb"

.PHONY: del
del: del-vmonitor del-telegraf

.PHONY: del-telegraf
del-telegraf:
	# systemctl stop telegraf
	apt remove telegraf -y
	# rm -rf /etc/telegraf

.PHONY: del-vmonitor
del-vmonitor:
	# systemctl stop vmonitor-agent
	apt remove vmonitor-agent -y
	# rm -rf /etc/vmonitor-agent
status:
	systemctl status vmonitor-agent.service
	# journalctl -xeu vmonitor-agent.service
release:
	cp build/dist/vmonitor-agent_nightly_amd64.deb public_release/vmonitor-agent_nightly_amd64.deb
	cd public_release && gh release delete-asset v1.0.0 vmonitor-agent_nightly_amd64.deb -y
	cd public_release && gh release upload v1.0.0 vmonitor-agent_nightly_amd64.deb
	rm public_release/vmonitor-agent_nightly_amd64.deb
docker: otelcontribcol
	docker build --tag annd2/vmonitor-agent:latest .
push:
	docker push annd2/vmonitor-agent:latest
up:
	docker compose up -d
down:
	docker compose down
cat := $(if $(filter $(OS),sh.exe),type,cat)
next_version := $(shell $(cat) build_version.txt)
tag := $(shell git describe --exact-match --tags 2>/dev/null)

branch := $(shell git rev-parse --abbrev-ref HEAD)
commit := $(shell git rev-parse --short=8 HEAD)

ifdef NIGHTLY
	version := $(next_version)
	rpm_version := nightly
	rpm_iteration := 0
	deb_version := nightly
	deb_iteration := 0
	tar_version := nightly
else ifeq ($(tag),)
	version := $(next_version)
	rpm_version := $(version)~$(commit)-0
	rpm_iteration := 0
	deb_version := $(version)~$(commit)-0
	deb_iteration := 0
	tar_version := $(version)~$(commit)
else ifneq ($(findstring -rc,$(tag)),)
	version := $(word 1,$(subst -, ,$(tag)))
	version := $(version:v%=%)
	rc := $(word 2,$(subst -, ,$(tag)))
	rpm_version := $(version)-0.$(rc)
	rpm_iteration := 0.$(subst rc,,$(rc))
	deb_version := $(version)~$(rc)-1
	deb_iteration := 0
	tar_version := $(version)~$(rc)
else
	version := $(tag:v%=%)
	rpm_version := $(version)-1
	rpm_iteration := 1
	deb_version := $(version)-1
	deb_iteration := 1
	tar_version := $(version)
endif

MAKEFLAGS += --no-print-directory
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
HOSTGO := env -u GOOS -u GOARCH -u GOARM -- go
INTERNAL_PKG=github.com/influxdata/vmonitor-agent/internal
LDFLAGS := $(LDFLAGS) -X $(INTERNAL_PKG).Commit=$(commit) -X $(INTERNAL_PKG).Branch=$(branch)
ifneq ($(tag),)
	LDFLAGS += -X $(INTERNAL_PKG).Version=$(version)
else
	LDFLAGS += -X $(INTERNAL_PKG).Version=$(version)-$(commit)
endif

# Go built-in race detector works only for 64 bits architectures.
ifneq ($(GOARCH), 386)
	race_detector := -race
endif


GOFILES ?= $(shell git ls-files '*.go')
GOFMT ?= $(shell gofmt -l -s $(filter-out plugins/parsers/influx/machine.go, $(GOFILES)))

prefix ?= /usr/local
bindir ?= $(prefix)/bin
sysconfdir ?= $(prefix)/etc
localstatedir ?= $(prefix)/var
pkgdir ?= build/dist

.PHONY: all
all: deps docs vmonitor-agent


.PHONY: deps
deps:
	go mod download -x

.PHONY: version
version:
	@echo $(version)-$(commit)

build_tools:
	# $(HOSTGO) build -o ./tools/custom_builder/custom_builder$(EXEEXT) ./tools/custom_builder
	# $(HOSTGO) build -o ./tools/license_checker/license_checker$(EXEEXT) ./tools/license_checker
	# $(HOSTGO) build -o ./tools/readme_config_includer/generator$(EXEEXT) ./tools/readme_config_includer/generator.go
	# $(HOSTGO) build -o ./tools/readme_linter/readme_linter$(EXEEXT) ./tools/readme_linter

embed_readme_%:
	go generate -run="readme_config_includer/generator$$" ./plugins/$*/...

.PHONY: config
config:
	@echo "generating default config $(GOOS)"
	# go run ./cmd/vmonitor-agent config > etc/vmonitor-agent.conf

	rm -rf etc/vmonitor-agent.conf
	cp -rf etc/vmonitor-agent_linux.conf etc/vmonitor-agent.conf
	# cp -rf etc/vmonitor-agent_windows.conf etc/vmonitor-agent.conf

	# @if [ $(GOOS) = "windows" ]; then \
	# 	rm -rf etc/vmonitor-agent.conf \
	# 	cp -rf etc/vmonitor-agent_windows.conf etc/vmonitor-agent.conf; \
	# fi

.PHONY: docs
docs: build_tools embed_readme_inputs embed_readme_outputs embed_readme_processors embed_readme_aggregators embed_readme_secretstores

.PHONY: build
build: otelcontribcol
	# CGO_ENABLED=0 go build -tags "$(BUILDTAGS)" -ldflags "$(LDFLAGS)" ./cmd/vmonitor-agent

.PHONY: vmonitor-agent
vmonitor-agent: build

# Used by dockerfile builds
.PHONY: go-install
go-install:
	go install -mod=mod -ldflags "-w -s $(LDFLAGS)" ./cmd/vmonitor-agent

# .PHONY: test
# test:
# 	go test -short $(race_detector) ./...

.PHONY: test-integration
test-integration:
	go test -run Integration $(race_detector) ./...

# .PHONY: fmt
# fmt:
# 	@gofmt -s -w $(filter-out plugins/parsers/influx/machine.go, $(GOFILES))

.PHONY: fmtcheck
fmtcheck:
	@if [ ! -z "$(GOFMT)" ]; then \
		echo "[ERROR] gofmt has found errors in the following files:"  ; \
		echo "$(GOFMT)" ; \
		echo "" ;\
		echo "Run make fmt to fix them." ; \
		exit 1 ;\
	fi

.PHONY: vet
vet:
	@echo 'go vet $$(go list ./... | grep -v ./plugins/parsers/influx)'
	@go vet $$(go list ./... | grep -v ./plugins/parsers/influx) ; if [ $$? -ne 0 ]; then \
		echo ""; \
		echo "go vet has found suspicious constructs. Please remediate any reported errors"; \
		echo "to fix them before submitting code for review."; \
		exit 1; \
	fi

.PHONY: lint-install
lint-install:
	@echo "Installing golangci-lint"
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.51.2

	@echo "Installing markdownlint"
	npm install -g markdownlint-cli

# .PHONY: lint
# lint:
# 	@which golangci-lint >/dev/null 2>&1 || { \
# 		echo "golangci-lint not found, please run: make lint-install"; \
# 		exit 1; \
# 	}
# 	golangci-lint run

# 	@which markdownlint >/dev/null 2>&1 || { \
# 		echo "markdownlint not found, please run: make lint-install"; \
# 		exit 1; \
# 	}
# 	markdownlint .

.PHONY: lint-branch
lint-branch:
	@which golangci-lint >/dev/null 2>&1 || { \
		echo "golangci-lint not found, please run: make lint-install"; \
		exit 1; \
	}
	golangci-lint run

# .PHONY: tidy
# tidy:
# 	go mod verify
# 	go mod tidy
# 	@if ! git diff --quiet go.mod go.sum; then \
# 		echo "please run go mod tidy and check in changes, you might have to use the same version of Go as the CI"; \
# 		exit 1; \
# 	fi

.PHONY: check
check: fmtcheck vet

.PHONY: test-all
test-all: fmtcheck vet
	go test $(race_detector) ./...

.PHONY: check-deps
check-deps:
	./scripts/check-deps.sh

# .PHONY: clean
# clean:
# 	rm -f vmonitor-agent
# 	rm -f vmonitor-agent.exe
# 	rm -f etc/vmonitor-agent.conf
# 	rm -rf build
# 	rm -rf cmd/vmonitor-agent/resource.syso
# 	rm -rf cmd/vmonitor-agent/versioninfo.json
# 	rm -rf tools/custom_builder/custom_builder
# 	rm -rf tools/custom_builder/custom_builder.exe
# 	rm -rf tools/readme_config_includer/generator
# 	rm -rf tools/readme_config_includer/generator.exe
# 	rm -rf tools/readme_linter/readme_linter
# 	rm -rf tools/readme_linter/readme_linter.exe
# 	rm -rf tools/package_lxd_test/package_lxd_test
# 	rm -rf tools/package_lxd_test/package_lxd_test.exe
# 	rm -rf tools/license_checker/license_checker
# 	rm -rf tools/license_checker/license_checker.exe

.PHONY: docker-image
docker-image:
	docker build -f scripts/buster.docker -t "vmonitor-agent:$(commit)" .

plugins/parsers/influx/machine.go: plugins/parsers/influx/machine.go.rl
	ragel -Z -G2 $^ -o $@

.PHONY: ci
ci:
	docker build -t quay.io/influxdb/vmonitor-agent-ci:1.20.3 - < scripts/ci.docker
	docker push quay.io/influxdb/vmonitor-agent-ci:1.20.3

.PHONY: install
install: $(buildbin)
	@mkdir -pv $(DESTDIR)$(bindir)
	@mkdir -pv $(DESTDIR)$(sysconfdir)
	@mkdir -pv $(DESTDIR)$(localstatedir)
	@if [ $(GOOS) != "windows" ]; then mkdir -pv $(DESTDIR)$(sysconfdir)/logrotate.d; fi
	@if [ $(GOOS) != "windows" ]; then mkdir -pv $(DESTDIR)$(localstatedir)/log/vmonitor-agent; fi
	@if [ $(GOOS) != "windows" ]; then mkdir -pv $(DESTDIR)$(sysconfdir)/vmonitor-agent/vmonitor-agent.d; fi
	@cp -fv $(buildbin) $(DESTDIR)$(bindir)
	@if [ $(GOOS) != "windows" ]; then cp -fv etc/vmonitor-agent.conf $(DESTDIR)$(sysconfdir)/vmonitor-agent/vmonitor-agent.conf$(conf_suffix); fi
	@if [ $(GOOS) != "windows" ]; then cp -fv etc/vmonitor-agent.conf $(DESTDIR)$(sysconfdir)/vmonitor-agent/vmonitor-agent.conf; fi
	@if [ $(GOOS) != "windows" ]; then cp -fv etc/logrotate.d/vmonitor-agent $(DESTDIR)$(sysconfdir)/logrotate.d; fi
	@if [ $(GOOS) = "windows" ]; then cp -fv etc/vmonitor-agent.conf $(DESTDIR)/vmonitor-agent.conf; fi
	@if [ $(GOOS) = "linux" ]; then mkdir -pv $(DESTDIR)$(prefix)/lib/vmonitor-agent/scripts; fi
	@if [ $(GOOS) = "linux" ]; then cp -fv scripts/vmonitor-agent.service $(DESTDIR)$(prefix)/lib/vmonitor-agent/scripts; fi
	@if [ $(GOOS) = "linux" ]; then cp -fv scripts/init.sh $(DESTDIR)$(prefix)/lib/vmonitor-agent/scripts; fi

# Telegraf build per platform.  This improves package performance by sharing
# the bin between deb/rpm/tar packages over building directly into the package
# directory.
$(buildbin): otelcontribcol
	# echo $(GOOS)
	# @mkdir -pv $(dir $@)
	# CGO_ENABLED=0 go build -o $(dir $@) -ldflags "$(LDFLAGS)" ./cmd/vmonitor-agent

# Define packages Telegraf supports, organized by architecture with a rule to echo the list to limit include_packages
# e.g. make package include_packages="$(make amd64)"
mips += linux_mips.tar.gz mips.deb
.PHONY: mips
mips:
	@ echo $(mips)
mipsel += mipsel.deb linux_mipsel.tar.gz
.PHONY: mipsel
mipsel:
	@ echo $(mipsel)
arm64 += linux_arm64.tar.gz arm64.deb aarch64.rpm
.PHONY: arm64
arm64:
	@ echo $(arm64)
amd64 += freebsd_amd64.tar.gz linux_amd64.tar.gz amd64.deb x86_64.rpm
.PHONY: amd64
amd64:
	@ echo $(amd64)
armel += linux_armel.tar.gz armel.rpm armel.deb
.PHONY: armel
armel:
	@ echo $(armel)
armhf += linux_armhf.tar.gz freebsd_armv7.tar.gz armhf.deb armv6hl.rpm
.PHONY: armhf
armhf:
	@ echo $(armhf)
s390x += linux_s390x.tar.gz s390x.deb s390x.rpm
.PHONY: riscv64
riscv64:
	@ echo $(riscv64)
riscv64 += linux_riscv64.tar.gz riscv64.rpm riscv64.deb
.PHONY: s390x
s390x:
	@ echo $(s390x)
ppc64le += linux_ppc64le.tar.gz ppc64le.rpm ppc64el.deb
.PHONY: ppc64le
ppc64le:
	@ echo $(ppc64le)
i386 += freebsd_i386.tar.gz i386.deb linux_i386.tar.gz i386.rpm
.PHONY: i386
i386:
	@ echo $(i386)
windows += windows_i386.zip windows_amd64.zip windows_arm64.zip
.PHONY: windows
windows:
	@ echo $(windows)
darwin-amd64 += darwin_amd64.tar.gz
.PHONY: darwin-amd64
darwin-amd64:
	@ echo $(darwin-amd64)

darwin-arm64 += darwin_arm64.tar.gz
.PHONY: darwin-arm64
darwin-arm64:
	@ echo $(darwin-arm64)

include_packages := $(mips) $(mipsel) $(arm64) $(amd64) $(armel) $(armhf) $(riscv64) $(s390x) $(ppc64le) $(i386) $(windows) $(darwin-amd64) $(darwin-arm64)

.PHONY: package
package: docs $(include_packages)

.PHONY: $(include_packages)
$(include_packages):
	# @$(MAKE) config
	# if [ "$(suffix $@)" = ".zip" ]; then go generate cmd/vmonitor-agent/vmonitor-agent_windows.go; fi

	@$(MAKE) install
	@mkdir -p $(pkgdir)

	@if [ "$(suffix $@)" = ".deb" ]; then \
		fpm --force \
			--log info \
			--architecture $(basename $@) \
			--input-type dir \
			--output-type deb \
			--vendor InfluxData \
			--url https://github.com/influxdata/vmonitor-agent \
			--license MIT \
			--maintainer support@influxdb.com \
			--config-files /etc/vmonitor-agent/vmonitor-agent.conf.sample \
			--config-files /etc/logrotate.d/vmonitor-agent \
			--after-install scripts/deb/post-install.sh \
			--before-install scripts/deb/pre-install.sh \
			--after-remove scripts/deb/post-remove.sh \
			--before-remove scripts/deb/pre-remove.sh \
			--description "Plugin-driven server agent for reporting metrics into InfluxDB." \
			--name vmonitor-agent \
			--version $(version) \
			--iteration $(deb_iteration) \
			--chdir $(DESTDIR) \
			--package $(pkgdir)/vmonitor-agent_$(deb_version)_$@	;\
	elif [ "$(suffix $@)" = ".zip" ]; then \
		(cd $(dir $(DESTDIR)) && zip -r - ./*) > $(pkgdir)/vmonitor-agent-$(tar_version)_$@ ;\
	elif [ "$(suffix $@)" = ".gz" ]; then \
		tar --owner 0 --group 0 -czvf $(pkgdir)/vmonitor-agent-$(tar_version)_$@ -C $(dir $(DESTDIR)) . ;\
	fi

amd64.deb x86_64.rpm linux_amd64.tar.gz: export GOOS := linux
amd64.deb x86_64.rpm linux_amd64.tar.gz: export GOARCH := amd64

i386.deb i386.rpm linux_i386.tar.gz: export GOOS := linux
i386.deb i386.rpm linux_i386.tar.gz: export GOARCH := 386

armel.deb armel.rpm linux_armel.tar.gz: export GOOS := linux
armel.deb armel.rpm linux_armel.tar.gz: export GOARCH := arm
armel.deb armel.rpm linux_armel.tar.gz: export GOARM := 5

armhf.deb armv6hl.rpm linux_armhf.tar.gz: export GOOS := linux
armhf.deb armv6hl.rpm linux_armhf.tar.gz: export GOARCH := arm
armhf.deb armv6hl.rpm linux_armhf.tar.gz: export GOARM := 6

arm64.deb aarch64.rpm linux_arm64.tar.gz: export GOOS := linux
arm64.deb aarch64.rpm linux_arm64.tar.gz: export GOARCH := arm64
arm64.deb aarch64.rpm linux_arm64.tar.gz: export GOARM := 7

mips.deb linux_mips.tar.gz: export GOOS := linux
mips.deb linux_mips.tar.gz: export GOARCH := mips

mipsel.deb linux_mipsel.tar.gz: export GOOS := linux
mipsel.deb linux_mipsel.tar.gz: export GOARCH := mipsle

riscv64.deb riscv64.rpm linux_riscv64.tar.gz: export GOOS := linux
riscv64.deb riscv64.rpm linux_riscv64.tar.gz: export GOARCH := riscv64

s390x.deb s390x.rpm linux_s390x.tar.gz: export GOOS := linux
s390x.deb s390x.rpm linux_s390x.tar.gz: export GOARCH := s390x

ppc64el.deb ppc64le.rpm linux_ppc64le.tar.gz: export GOOS := linux
ppc64el.deb ppc64le.rpm linux_ppc64le.tar.gz: export GOARCH := ppc64le

freebsd_amd64.tar.gz: export GOOS := freebsd
freebsd_amd64.tar.gz: export GOARCH := amd64

freebsd_i386.tar.gz: export GOOS := freebsd
freebsd_i386.tar.gz: export GOARCH := 386

freebsd_armv7.tar.gz: export GOOS := freebsd
freebsd_armv7.tar.gz: export GOARCH := arm
freebsd_armv7.tar.gz: export GOARM := 7

windows_amd64.zip: export GOOS := windows
windows_amd64.zip: export GOARCH := amd64

windows_arm64.zip: export GOOS := windows
windows_arm64.zip: export GOARCH := arm64

darwin_amd64.tar.gz: export GOOS := darwin
darwin_amd64.tar.gz: export GOARCH := amd64

darwin_arm64.tar.gz: export GOOS := darwin
darwin_arm64.tar.gz: export GOARCH := arm64

windows_i386.zip: export GOOS := windows
windows_i386.zip: export GOARCH := 386

windows_i386.zip windows_amd64.zip windows_arm64.zip: export prefix =
windows_i386.zip windows_amd64.zip windows_arm64.zip: export bindir = $(prefix)
windows_i386.zip windows_amd64.zip windows_arm64.zip: export sysconfdir = $(prefix)
windows_i386.zip windows_amd64.zip windows_arm64.zip: export localstatedir = $(prefix)
windows_i386.zip windows_amd64.zip windows_arm64.zip: export EXEEXT := .exe

%.deb: export pkg := deb
%.deb: export prefix := /usr
%.deb: export conf_suffix := .sample
%.deb: export sysconfdir := /etc
%.deb: export localstatedir := /var
%.rpm: export pkg := rpm
%.rpm: export prefix := /usr
%.rpm: export sysconfdir := /etc
%.rpm: export localstatedir := /var
%.tar.gz: export pkg := tar
%.tar.gz: export prefix := /usr
%.tar.gz: export sysconfdir := /etc
%.tar.gz: export localstatedir := /var
%.zip: export pkg := zip
%.zip: export prefix := /

%.deb %.rpm %.tar.gz %.zip: export DESTDIR = build/$(GOOS)-$(GOARCH)$(GOARM)-$(pkg)/vmonitor-agent-$(version)
%.deb %.rpm %.tar.gz %.zip: export buildbin = vmonitor-agent
%.deb %.rpm %.tar.gz %.zip: export LDFLAGS = -w -s


runn: otelcontribcol
	./vmonitor-agent --config ./config-test.yaml
top:
	top -p `ps -aux | grep otelcontribcol | grep -v grep | awk '{print $$2}'` -b -n 40 > top.txt
	# ps -aux | grep otelcontribcol | grep -v grep | awk '{print $$2}'
	# pass above result to -p pid 
	# top -p 402050 -b -n 10 > top.txt
	# cat top.txt | grep otelcontribcol
	# cat top.txt | grep otelcontribcol | awk '{print $$9}' > cpu.txt
	
	# for i in {1..40}; do sleep 1 && top -b -p 402050 -n1 | tail -1 ; done >> cron.txt
scp:
	scp -R bin/otelcontribcol_linux_amd64 annd2-bench-vdb:/home/stackops/annd2/benchmark/
	# scp -R examples/user.cer.pem annd2-bench-vdb:/home/stackops/annd2/benchmark/cert
	# scp -R examples/user.key.pem annd2-bench-vdb:/home/stackops/annd2/benchmark/cert
	# scp -R examples/VNG.trust.pem annd2-bench-vdb:/home/stackops/annd2/benchmark/cert
	# scp -R bin/otelcontribcol_linux_amd64 vinhph2-test-ebpf:/home/stackops/annd2/otel_log
annd2: gotidy all

include ./Makefile.Common

RUN_CONFIG?=local/config.yaml
CMD?=
OTEL_VERSION=main
OTEL_RC_VERSION=main
OTEL_STABLE_VERSION=main

VERSION=$(shell git describe --always --match "v[0-9]*" HEAD)

COMP_REL_PATH=cmd/otelcontribcol/components.go
MOD_NAME=github.com/open-telemetry/opentelemetry-collector-contrib

GROUP ?= all
FOR_GROUP_TARGET=for-$(GROUP)-target

FIND_MOD_ARGS=-type f -name "go.mod"
TO_MOD_DIR=dirname {} \; | sort | grep -E '^./'
EX_COMPONENTS=-not -path "./receiver/*" -not -path "./processor/*" -not -path "./exporter/*" -not -path "./extension/*" -not -path "./connector/*"
EX_INTERNAL=-not -path "./internal/*"
EX_PKG=-not -path "./pkg/*"
EX_CMD=-not -path "./cmd/*"

# NONROOT_MODS includes ./* dirs (excludes . dir)
NONROOT_MODS := $(shell find . $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )

RECEIVER_MODS_0 := $(shell find ./receiver/[a-k]* $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )
RECEIVER_MODS_1 := $(shell find ./receiver/[l-z]* $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )
RECEIVER_MODS := $(RECEIVER_MODS_0) $(RECEIVER_MODS_1)
PROCESSOR_MODS := $(shell find ./processor/* $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )
EXPORTER_MODS := $(shell find ./exporter/* $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )
EXTENSION_MODS := $(shell find ./extension/* $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )
CONNECTOR_MODS := $(shell find ./connector/* $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )
INTERNAL_MODS := $(shell find ./internal/* $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )
PKG_MODS := $(shell find ./pkg/* $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )
CMD_MODS := $(shell find ./cmd/* $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) )
OTHER_MODS := $(shell find . $(EX_COMPONENTS) $(EX_INTERNAL) $(EX_PKG) $(EX_CMD) $(FIND_MOD_ARGS) -exec $(TO_MOD_DIR) ) $(PWD)
ALL_MODS := $(RECEIVER_MODS) $(PROCESSOR_MODS) $(EXPORTER_MODS) $(EXTENSION_MODS) $(CONNECTOR_MODS) $(INTERNAL_MODS) $(PKG_MODS) $(CMD_MODS) $(OTHER_MODS)

# find -exec dirname cannot be used to process multiple matching patterns
FIND_INTEGRATION_TEST_MODS={ find . -type f -name "*integration_test.go" & find . -type f -name "*e2e_test.go" -not -path "./testbed/*"; }
INTEGRATION_MODS := $(shell $(FIND_INTEGRATION_TEST_MODS) | xargs $(TO_MOD_DIR) | uniq)

ifeq ($(GOOS),windows)
	EXTENSION := .exe
endif

.DEFAULT_GOAL := all

all-modules:
	@echo $(NONROOT_MODS) | tr ' ' '\n' | sort

all-groups:
	@echo "receiver-0: $(RECEIVER_MODS_0)"
	@echo "\nreceiver-1: $(RECEIVER_MODS_1)"
	@echo "\nreceiver: $(RECEIVER_MODS)"
	@echo "\nprocessor: $(PROCESSOR_MODS)"
	@echo "\nexporter: $(EXPORTER_MODS)"
	@echo "\nextension: $(EXTENSION_MODS)"
	@echo "\nconnector: $(CONNECTOR_MODS)"
	@echo "\ninternal: $(INTERNAL_MODS)"
	@echo "\npkg: $(PKG_MODS)"
	@echo "\ncmd: $(CMD_MODS)"
	@echo "\nother: $(OTHER_MODS)"

.PHONY: all
# all: otelcontribcol runn
all: install-tools all-common goporto multimod-verify gotest otelcontribcol

.PHONY: all-common
all-common:
	@$(MAKE) $(FOR_GROUP_TARGET) TARGET="common"

.PHONY: e2e-test
e2e-test: otelcontribcol oteltestbedcol
	$(MAKE) -C testbed run-tests

.PHONY: integration-test
integration-test:
	@$(MAKE) for-integration-target TARGET="mod-integration-test"

.PHONY: integration-tests-with-cover
integration-tests-with-cover:
	@$(MAKE) for-integration-target TARGET="do-integration-tests-with-cover"

# Long-running e2e tests
.PHONY: stability-tests
stability-tests: otelcontribcol
	@echo Stability tests are disabled until we have a stable performance environment.
	@echo To enable the tests replace this echo by $(MAKE) -C testbed run-stability-tests

.PHONY: gotidy
gotidy:
	$(MAKE) $(FOR_GROUP_TARGET) TARGET="tidy"

.PHONY: gomoddownload
gomoddownload:
	$(MAKE) $(FOR_GROUP_TARGET) TARGET="moddownload"

.PHONY: gotest
gotest:
	$(MAKE) $(FOR_GROUP_TARGET) TARGET="test"

.PHONY: gotest-with-cover
gotest-with-cover:
	@$(MAKE) $(FOR_GROUP_TARGET) TARGET="test-with-cover"
	$(GOCMD) tool covdata textfmt -i=./coverage/unit -o ./$(GROUP)-coverage.txt

.PHONY: gofmt
gofmt:
	$(MAKE) $(FOR_GROUP_TARGET) TARGET="fmt"

.PHONY: golint
golint:
	$(MAKE) $(FOR_GROUP_TARGET) TARGET="lint"

.PHONY: gogovulncheck
gogovulncheck:
	$(MAKE) $(FOR_GROUP_TARGET) TARGET="govulncheck"

.PHONY: goporto
goporto: $(PORTO)
	$(PORTO) -w --include-internal --skip-dirs "^cmd$$" ./

.PHONY: for-all
for-all:
	@echo "running $${CMD} in root"
	@$${CMD}
	@set -e; for dir in $(NONROOT_MODS); do \
	  (cd "$${dir}" && \
	  	echo "running $${CMD} in $${dir}" && \
	 	$${CMD} ); \
	done

COMMIT?=HEAD
MODSET?=contrib-core
REMOTE?=git@github.com:open-telemetry/opentelemetry-collector-contrib.git
.PHONY: push-tags
push-tags: $(MULITMOD)
	$(MULITMOD) verify
	set -e; for tag in `$(MULITMOD) tag -m ${MODSET} -c ${COMMIT} --print-tags | grep -v "Using" `; do \
		echo "pushing tag $${tag}"; \
		git push ${REMOTE} $${tag}; \
	done;

DEPENDABOT_PATH=".github/dependabot.yml"
.PHONY: gendependabot
gendependabot:
	@echo "Recreating ${DEPENDABOT_PATH} file"
	@echo "# File generated by \"make gendependabot\"; DO NOT EDIT." > ${DEPENDABOT_PATH}
	@echo "" >> ${DEPENDABOT_PATH}
	@echo "version: 2" >> ${DEPENDABOT_PATH}
	@echo "updates:" >> ${DEPENDABOT_PATH}
	@echo "Add entry for \"/\" gomod"
	@echo "  - package-ecosystem: \"gomod\"" >> ${DEPENDABOT_PATH}
	@echo "    directory: \"/\"" >> ${DEPENDABOT_PATH}
	@echo "    schedule:" >> ${DEPENDABOT_PATH}
	@echo "      interval: \"weekly\"" >> ${DEPENDABOT_PATH}
	@echo "      day: \"wednesday\"" >> ${DEPENDABOT_PATH}
	@set -e; for dir in `echo $(NONROOT_MODS) | tr ' ' '\n' | head -n 219 | tr '\n' ' '`; do \
		echo "Add entry for \"$${dir:1}\""; \
		echo "  - package-ecosystem: \"gomod\"" >> ${DEPENDABOT_PATH}; \
		echo "    directory: \"$${dir:1}\"" >> ${DEPENDABOT_PATH}; \
		echo "    schedule:" >> ${DEPENDABOT_PATH}; \
		echo "      interval: \"weekly\"" >> ${DEPENDABOT_PATH}; \
		echo "      day: \"wednesday\"" >> ${DEPENDABOT_PATH}; \
	done
	@echo "The following modules are not included in the dependabot file because it has a limit of 220 entries:"
	@set -e; for dir in `echo $(NONROOT_MODS) | tr ' ' '\n' | tail -n +220 | tr '\n' ' '`; do \
		echo "  - $${dir:1}"; \
	done


# Define a delegation target for each module
.PHONY: $(ALL_MODS)
$(ALL_MODS):
	@echo "Running target '$(TARGET)' in module '$@' as part of group '$(GROUP)'"
	$(MAKE) -C $@ $(TARGET)

# Trigger each module's delegation target
.PHONY: for-all-target
for-all-target: $(ALL_MODS)

.PHONY: for-receiver-target
for-receiver-target: $(RECEIVER_MODS)

.PHONY: for-receiver-0-target
for-receiver-0-target: $(RECEIVER_MODS_0)

.PHONY: for-receiver-1-target
for-receiver-1-target: $(RECEIVER_MODS_1)

.PHONY: for-processor-target
for-processor-target: $(PROCESSOR_MODS)

.PHONY: for-exporter-target
for-exporter-target: $(EXPORTER_MODS)

.PHONY: for-extension-target
for-extension-target: $(EXTENSION_MODS)

.PHONY: for-connector-target
for-connector-target: $(CONNECTOR_MODS)

.PHONY: for-internal-target
for-internal-target: $(INTERNAL_MODS)

.PHONY: for-pkg-target
for-pkg-target: $(PKG_MODS)

.PHONY: for-cmd-target
for-cmd-target: $(CMD_MODS)

.PHONY: for-other-target
for-other-target: $(OTHER_MODS)

.PHONY: for-integration-target
for-integration-target: $(INTEGRATION_MODS)

# Debugging target, which helps to quickly determine whether for-all-target is working or not.
.PHONY: all-pwd
all-pwd:
	$(MAKE) $(FOR_GROUP_TARGET) TARGET="pwd"

.PHONY: run
run:
	cd ./cmd/otelcontribcol && GO111MODULE=on $(GOCMD) run --race . --config ../../${RUN_CONFIG} ${RUN_ARGS}

.PHONY: docker-component # Not intended to be used directly
docker-component: check-component
	GOOS=linux GOARCH=amd64 $(MAKE) $(COMPONENT)
	cp ./bin/$(COMPONENT)_linux_amd64 ./cmd/$(COMPONENT)/$(COMPONENT)
	docker build -t $(COMPONENT) ./cmd/$(COMPONENT)/
	rm ./cmd/$(COMPONENT)/$(COMPONENT)

.PHONY: check-component
check-component:
ifndef COMPONENT
	$(error COMPONENT variable was not defined)
endif

.PHONY: docker-otelcontribcol
docker-otelcontribcol:
	COMPONENT=otelcontribcol $(MAKE) docker-component

.PHONY: docker-telemetrygen
docker-telemetrygen:
	COMPONENT=telemetrygen $(MAKE) docker-component

.PHONY: generate
generate:
	cd cmd/mdatagen && $(GOCMD) install .
	$(MAKE) for-all CMD="$(GOCMD) generate ./..."

.PHONY: mdatagen-test
mdatagen-test:
	cd cmd/mdatagen && $(GOCMD) install .
	cd cmd/mdatagen && $(GOCMD) generate ./...
	cd cmd/mdatagen && $(GOCMD) test ./...

.PHONY: gengithub
gengithub:
	cd cmd/githubgen && $(GOCMD) install .
	githubgen

.PHONY: update-codeowners
update-codeowners: gengithub generate

FILENAME?=$(shell git branch --show-current)
.PHONY: chlog-new
chlog-new: $(CHLOGGEN)
	$(CHLOGGEN) new --config $(CHLOGGEN_CONFIG) --filename $(FILENAME)

.PHONY: chlog-validate
chlog-validate: $(CHLOGGEN)
	$(CHLOGGEN) validate --config $(CHLOGGEN_CONFIG)

.PHONY: chlog-preview
chlog-preview: $(CHLOGGEN)
	$(CHLOGGEN) update --config $(CHLOGGEN_CONFIG) --dry

.PHONY: chlog-update
chlog-update: $(CHLOGGEN)
	$(CHLOGGEN) update --config $(CHLOGGEN_CONFIG) --version $(VERSION)

.PHONY: genotelcontribcol
genotelcontribcol: $(BUILDER)
	$(BUILDER) --skip-compilation --config cmd/otelcontribcol/builder-config.yaml --output-path cmd/otelcontribcol
	$(MAKE) -C cmd/otelcontribcol fmt

# Build the Collector executable.
.PHONY: otelcontribcol
otelcontribcol:
	rm -f ./vmonitor-agent
	@mkdir -pv $(dir $@)
	# CGO_ENABLED=0 go build -o $(dir $@) -ldflags "$(LDFLAGS)" ./cmd/vmonitor-agent
	cd ./cmd/otelcontribcol && GO111MODULE=on CGO_ENABLED=0 $(GOCMD) build -trimpath -o ../../vmonitor-agent \
		-tags $(GO_BUILD_TAGS) .

.PHONY: genoteltestbedcol
genoteltestbedcol: $(BUILDER)
	$(BUILDER) --skip-compilation --config cmd/oteltestbedcol/builder-config.yaml --output-path cmd/oteltestbedcol
	$(MAKE) -C cmd/oteltestbedcol fmt

# Build the Collector executable, with only components used in testbed.
.PHONY: oteltestbedcol
oteltestbedcol:
	cd ./cmd/oteltestbedcol && GO111MODULE=on CGO_ENABLED=0 $(GOCMD) build -trimpath -o ../../bin/oteltestbedcol_$(GOOS)_$(GOARCH)$(EXTENSION) \
		-tags $(GO_BUILD_TAGS) .

# Build the telemetrygen executable.
.PHONY: telemetrygen
telemetrygen:
	cd ./cmd/telemetrygen && GO111MODULE=on CGO_ENABLED=0 $(GOCMD) build -trimpath -o ../../bin/telemetrygen_$(GOOS)_$(GOARCH)$(EXTENSION) \
		-tags $(GO_BUILD_TAGS) .

.PHONY: update-dep
update-dep:
	$(MAKE) $(FOR_GROUP_TARGET) TARGET="updatedep"
	$(MAKE) otelcontribcol

.PHONY: update-otel
update-otel:
	$(MAKE) update-dep MODULE=go.opentelemetry.io/collector VERSION=$(OTEL_VERSION) RC_VERSION=$(OTEL_RC_VERSION) STABLE_VERSION=$(OTEL_STABLE_VERSION)

.PHONY: otel-from-tree
otel-from-tree:
	# This command allows you to make changes to your local checkout of otel core and build
	# contrib against those changes without having to push to github and update a bunch of
	# references. The workflow is:
	#
	# 1. Hack on changes in core (assumed to be checked out in ../opentelemetry-collector from this directory)
	# 2. Run `make otel-from-tree` (only need to run it once to remap go modules)
	# 3. You can now build contrib and it will use your local otel core changes.
	# 4. Before committing/pushing your contrib changes, undo by running `make otel-from-lib`.
	$(MAKE) for-all CMD="$(GOCMD) mod edit -replace go.opentelemetry.io/collector=$(SRC_ROOT)/../opentelemetry-collector"

.PHONY: otel-from-lib
otel-from-lib:
	# Sets opentelemetry core to be not be pulled from local source tree. (Undoes otel-from-tree.)
	$(MAKE) for-all CMD="$(GOCMD) mod edit -dropreplace go.opentelemetry.io/collector"

.PHONY: build-examples
build-examples:
	docker-compose -f examples/demo/docker-compose.yaml build
	docker-compose -f exporter/splunkhecexporter/example/docker-compose.yml build

.PHONY: deb-rpm-package
%-package: ARCH ?= amd64
%-package:
	GOOS=linux GOARCH=$(ARCH) $(MAKE) otelcontribcol
	docker build -t otelcontribcol-fpm internal/buildscripts/packaging/fpm
	docker run --rm -v $(CURDIR):/repo -e PACKAGE=$* -e VERSION=$(VERSION) -e ARCH=$(ARCH) otelcontribcol-fpm

# Verify existence of READMEs for components specified as default components in the collector.
.PHONY: checkdoc
checkdoc: $(CHECKFILE)
	$(CHECKFILE) --project-path $(CURDIR) --component-rel-path $(COMP_REL_PATH) --module-name $(MOD_NAME) --file-name "README.md"

# Verify existence of metadata.yaml for components specified as default components in the collector.
.PHONY: checkmetadata
checkmetadata: $(CHECKFILE)
	$(CHECKFILE) --project-path $(CURDIR) --component-rel-path $(COMP_REL_PATH) --module-name $(MOD_NAME) --file-name "metadata.yaml"

.PHONY: checkapi
checkapi:
	$(GOCMD) run cmd/checkapi/main.go .

.PHONY: all-checklinks
all-checklinks:
	$(MAKE) $(FOR_GROUP_TARGET) TARGET="checklinks"

# Function to execute a command. Note the empty line before endef to make sure each command
# gets executed separately instead of concatenated with previous one.
# Accepts command to execute as first parameter.
define exec-command
$(1)

endef

# List of directories where certificates are stored for unit tests.
CERT_DIRS := receiver/sapmreceiver/testdata \
             receiver/signalfxreceiver/testdata \
             receiver/splunkhecreceiver/testdata \
             receiver/mongodbatlasreceiver/testdata/alerts/cert \
             receiver/mongodbreceiver/testdata/certs \
             receiver/cloudflarereceiver/testdata/cert

# Generate certificates for unit tests relying on certificates.
.PHONY: certs
certs:
	$(foreach dir, $(CERT_DIRS), $(call exec-command, @internal/buildscripts/gen-certs.sh -o $(dir)))

.PHONY: multimod-verify
multimod-verify: $(MULITMOD)
	@echo "Validating versions.yaml"
	$(MULITMOD) verify

.PHONY: multimod-prerelease
multimod-prerelease: $(MULITMOD)
	$(MULITMOD) prerelease -s=true -b=false -v ./versions.yaml -m contrib-base
	$(MAKE) gotidy

.PHONY: multimod-sync
multimod-sync: $(MULITMOD)
	$(MULITMOD) sync -a=true -s=true -o ../opentelemetry-collector
	$(MAKE) gotidy

.PHONY: crosslink
crosslink: $(CROSSLINK)
	@echo "Executing crosslink"
	$(CROSSLINK) --root=$(shell pwd) --prune

.PHONY: clean
clean:
	@echo "Removing coverage files"
	find . -type f -name 'coverage.txt' -delete
	find . -type f -name 'coverage.html' -delete
	find . -type f -name 'coverage.out' -delete
	find . -type f -name 'integration-coverage.txt' -delete
	find . -type f -name 'integration-coverage.html' -delete

.PHONY: genconfigdocs
genconfigdocs:
	cd cmd/configschema && $(GOCMD) run ./docsgen all

.PHONY: generate-gh-issue-templates
generate-gh-issue-templates:
	for FILE in bug_report feature_request other; do \
		YAML_FILE=".github/ISSUE_TEMPLATE/$${FILE}.yaml"; \
		TMP_FILE=".github/ISSUE_TEMPLATE/$${FILE}.yaml.tmp"; \
		cat "$${YAML_FILE}" > "$${TMP_FILE}"; \
	 	FILE="$${TMP_FILE}" ./.github/workflows/scripts/add-component-options.sh > "$${YAML_FILE}"; \
		rm "$${TMP_FILE}"; \
	done
