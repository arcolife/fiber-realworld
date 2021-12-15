#for newmand command HOST must be non-localhost 

HOST=localhost
#HOST=192.168.56.103
PORT=8585
CONTAINER_PORT=8585
#export APIURL=http://192.168.56.103:8585/api
export APIURL=http://$(HOST):$(PORT)/api

#export ROOT=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
GOOS=linux
GOARCH=amd64
APP=fiber-rw
APP_STATIC=$(APP)-static
LDFLAGS="-w -s -extldflags=-static"

USERNAME=u$(shell date +%s)
EMAIL=$(USERNAME)@mail.com
PASSWORD=password
NEWMAN_URL=https://github.com/gothinkster/realworld/raw/main/api/Conduit.postman_collection.json

#docker run -it -p8585:8585 --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp golang:1.17 make run
#docker run -it  --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp golang:1.17 go install  github.com/kyoh86/richgo && richgo test ./... 


help: ## Prints help for targets with comments
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

download: ## Download go dependency 
	go mod download

clear-db: ## Remove old database
	rm -f ./database/realworld.db

docs:
	go get -u github.com/swaggo/swag/cmd/swag
	go generate .

generate: ## Generate swagger docs. Required https://github.com/arsmn/fiber-swagger 
	go generate .	

build: ## Build project with dynamic library(see shared lib with "ldd <your_file>") 
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -race -o $(APP) . 

build-static: ## Build project as single static linked executable file
	GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0  go build -ldflags=$(LDFLAGS)  -o $(APP_STATIC) .

build-image: ## Build docker image. Required https://www.docker.com  
	docker build -t fiber-rw .

run: docs ## Run project 
	go run -race .

run-container: ## Run container аfter build-container. Required https://www.docker.com  
	chmod o+w ./database && docker run -p 8585:8585 -v $(PWD)/database:/myapp/database  fiber-rw:latest



test: ## Run unit test without race detection 
	go test -v ./...

test-race: ## Run unit test without race detection
	go test -v -race  ./...

rtest: ## Run unit test with rich format. Required https://github.com/kyoh86/richgo 
	richgo test -v ./...

rtest-race: ## Run unit test with rich format. Required https://github.com/kyoh86/richgo  
	richgo test -v -race  ./...

#local Rudiment 
#newmanl:
#	../../../realworld/api/run-api-tests-local.sh

newman: ## Run integration test. Required https://github.com/postmanlabs/newman 
	newman run  --delay-request $(DELAY_REQUEST) --global-var "APIURL=$(APIURL)"  --global-var "USERNAME=$(USERNAME)" --global-var "EMAIL=$(EMAIL)" --global-var "PASSWORD=$(PASSWORD)" $(NEWMAN_URL)

newmanx: ## Run integration test when Node.js installed. Required https://nodejs.org 
	npx newman run --bail --verbose  --delay-request $(DELAY_REQUEST) --global-var "APIURL=$(APIURL)"  --global-var "USERNAME=$(USERNAME)" --global-var "EMAIL=$(EMAIL)" --global-var "PASSWORD=$(PASSWORD)" $(NEWMAN_URL) 

newmand: ## Run integration test when Docker installed. Required https://www.docker.com 
ifeq ($(HOST),localhost)
	@echo  "Error. Change HOST variable to other ip address from local network (for example: 192.168.56.103)"
else
	docker run -i -p$(PORT):$(CONTAINER_PORT) --rm -t postman/newman_alpine33 run $(NEWMAN_URL) --delay-request $(DELAY_REQUEST) --global-var "APIURL=$(APIURL)"  --global-var "USERNAME=$(USERNAME)" --global-var "EMAIL=$(EMAIL)" --global-var "PASSWORD=$(PASSWORD)" 
endif

