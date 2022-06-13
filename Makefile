ifeq ($(OS),Windows_NT)
	SHELL := pwsh
else
	SHELL := /bin/bash
endif

.PHONY : check lint install-linters dep test build


RFC_3339 := "+%Y-%m-%dT%H:%M:%SZ"
COMMIT := $(shell git rev-list -1 HEAD)

ifeq ($(OS),Windows_NT)
	BIN := .\bin
    BIN_DIR?=.\bin
    CMD_DIR := .\cmd
	OPTS?=powershell -Command setx GO111MODULE on;
	.DEFAULT_GOAL := help-windows
else
	BIN := ${PWD}/bin
	BIN_DIR?=./bin
	CMD_DIR := ./cmd
	OPTS?=GO111MODULE=on
	.DEFAULT_GOAL := help
endif

TEST_OPTS:=-v -tags no_ci -cover -timeout=5m

RACE_FLAG:=-race
GOARCH:=$(shell go env GOARCH)

ifneq (,$(findstring 64,$(GOARCH)))
    TEST_OPTS:=$(TEST_OPTS) $(RACE_FLAG)
endif

check: lint test ## Run linters and tests

check-windows: lint test-windows ## Run linters and tests on windows

lint: ## Run linters. Use make install-linters first	
	${OPTS} golangci-lint run -c .golangci.yml ./...
	# The govet version in golangci-lint is out of date and has spurious warnings, run it separately
	${OPTS} go vet -all ./...

vendorcheck:  ## Run vendorcheck
	GO111MODULE=off vendorcheck ./...

test: ## Run tests
	-go clean -testcache &>/dev/null
	${OPTS} go test ${TEST_OPTS} ./...

test-windows: ## Run tests
	-go clean -testcache
	${OPTS} go test ${TEST_OPTS} ./...

install-linters: ## Install linters
	# GO111MODULE=off go get -u github.com/FiloSottile/vendorcheck
	# For some reason this install method is not recommended, see https://github.com/golangci/golangci-lint#install
	# However, they suggest `curl ... | bash` which we should not do
	${OPTS} go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	${OPTS} go install golang.org/x/tools/cmd/goimports@latest
	${OPTS} go install github.com/incu6us/goimports-reviser@latest

install-linters-windows: ## Install linters on windows
	${OPTS} go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	${OPTS} go install golang.org/x/tools/cmd/goimports@latest
	${OPTS} go install github.com/incu6us/goimports-reviser@latest

format: ## Formats the code. Must have goimports and goimports-reviser installed (use make install-linters).
	${OPTS} goimports -w -local ${DMSG_REPO} .

format-windows: ## Formats the code. Must have goimports and goimports-reviser installed (use make install-linters-windows).
	powershell -Command .\scripts\format-windows.ps1

dep: ## Sorts dependencies
	${OPTS} go mod vendor -v
	${OPTS} go mod tidy -v

help: ## Display help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

help-windows: ## Display help for windows
	@powershell 'Select-String -Pattern "windows[a-zA-Z_-]*:.*## .*$$" $(MAKEFILE_LIST) | % { $$_.Line -split ":.*?## " -Join "`t:`t" } '
