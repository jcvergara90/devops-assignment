.DEFAULT_GOAL := help
.PHONY: help


-include makefiles/makefile.*

## GENERAL ##
OWNER            = OWNER
PRODUCT          = api
CATEGORY         = ms
FUNCTION         = devops
HTTP_PORT       ?= 8080

## DEPLOY ##
PROJECT_DIR  = app
PROJECT_NAME = $(PRODUCT)-$(CATEGORY)-$(FUNCTION)
IMAGE = $(PROJECT_NAME):latest

## RESULT_VARS ##
ENV              ?= dev
DEPLOY_REGION    ?= us-east-2
AWS_PROFILE      ?= default

ECS_CLUSTER                ?= $(OWNER)
SECURITY_GROUP_NAME_FILTER ?= $(OWNER)-sg-service
SUBNETS_NAME_FILTER	       ?= $(OWNER)-private
DESIRED_COUNT              ?= 2
HTTP_PORT_TG               ?= 80
HOST_PORT                  ?= 80
CONTAINER_PORT             ?= 80
CONTAINER_CPU              ?= 256
CONTAINER_MEMORY           ?= 512
VPC_NAME_FILTER            ?= $(OWNER)-vpc
HEALTH_CHECK_PATH          ?= /health

## HELP ##
help:
	@printf "\033[31m%-25s %-38s %s\033[0m\n" "Target" "Help" "Usage"; \
	printf "\033[31m%-25s %-38s %s\033[0m\n" "------" "----" "-----"; \
	grep -hE '^\S+:.*## .*$$' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' | sort | awk 'BEGIN {FS = ":"}; {printf "\033[32m%-24s\033[0m %-38s \033[34m%s\033[0m\n", $$1, $$2, $$3}'

