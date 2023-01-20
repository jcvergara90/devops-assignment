.PHONY: ecr.login \
		ecr.create.repository \
		ecr.batch.delete.image \
		ecr.push.image \
		ecr.last.image.get

## DEPLOY ##
ACCOUNT_ID 		  ?= $(shell aws sts get-caller-identity --query "Account" --output text)
BUILD_TIMESTAMP   ?= $(shell date +'%Y%m%d')
BUILD_NUMBER 	  ?= $(shell date +'%H')
BRANCH_BUILD	  ?= $(shell git branch | grep '*' | awk '{print $$2}')

BUILD_NUMBER_DEPLOY = $(shell echo `printf %05d ${BUILD_NUMBER}`)
TAG_DEPLOY		    = ${BUILD_TIMESTAMP}.${BUILD_NUMBER}
IMAGE_DEPLOY	    = ${PROJECT_NAME}:${TAG_DEPLOY}
REGISTRY_ECR    	 = ${ACCOUNT_ID}.dkr.ecr.${DEPLOY_REGION}.amazonaws.com
MAX_IMAGES_ALLOWED  = 5


## TARGET ##

ecr.last.image.get:
	$(eval ECR_IMAGE_LATEST := ${PROJECT_NAME}:$(shell aws ecr describe-images --repository-name ${PROJECT_NAME} \
								--query 'imageDetails[*].imageTags[ * ]' --output text \
								--region $(DEPLOY_REGION) \
								| sort -r | head -n 1))

ecr.login: ## Login in ECR.: make ecr.login
	$(eval AWS_CLI_VERSION := $(shell aws --version \
									| cut -d " " -f 1 \
									| cut -d "/" -f 2 \
									| cut -d "." -f 1))

	@if [ $(AWS_CLI_VERSION) -gt 1 ]; then \
		aws ecr \
			get-login-password \
			--region $(DEPLOY_REGION) \
			| docker login \
				--username AWS \
				--password-stdin $(REGISTRY_ECR); \
	else \
		aws ecr \
			get-login \
			--no-include-email \
			--region $(DEPLOY_REGION) | sh; \
	fi

ecr.create.repository: ## Create repository in ECR.: make ecr.create.repository
	$(eval EXITS_REPOSITORY := $(shell aws ecr \
		describe-repositories \
		--repository-name ${PROJECT_NAME} \
		--region $(DEPLOY_REGION) \
		| grep "repositoryName" \
		| sed 's/repositoryName//g'\
		| sed 's/://g'| sed 's/,//g'| sed 's/ //g'| sed 's/"//g'))
	@if [ "${EXITS_REPOSITORY}" != "${PROJECT_NAME}" ]; then \
		$(info "Create repository ${PROJECT_NAME} in the region ${DEPLOY_REGION}...") \
		aws ecr create-repository --repository-name ${PROJECT_NAME} --region $(DEPLOY_REGION); \
	fi

ecr.batch.delete.image: ## Remove docker images from repository.: make ecr.batch.delete.image
	$(eval TOTAL_IMAGES := $(shell aws --region \
								${DEPLOY_REGION} \
								ecr list-images \
								--repository-name ${PROJECT_NAME} \
								| grep imageTag \
								| cut -d'"' -f4 \
								| sort -rn | wc -l))

	$(info "Total Imagen: $(TOTAL_IMAGES)")
	if [ ${TOTAL_IMAGES} -gt ${MAX_IMAGES_ALLOWED} ]; then \
		$(eval FILE_IMAGES:= $(shell echo '${PWD}/file_images.${BUILD_NUMBER_DEPLOY}')) \
		$(eval TOTAL_LINE:= $(shell echo '${TOTAL_IMAGES} - ${MAX_IMAGES_ALLOWED}' | bc)) \
		aws --region \
			${DEPLOY_REGION} \
			ecr list-images \
			--repository-name ${PROJECT_NAME} \
			| grep imageTag \
			| cut -d'"' -f4 \
			| sort -rn > ${FILE_IMAGES};\
		\
		for line in `cat ${FILE_IMAGES} | tail -n ${TOTAL_LINE}`; do \
			aws ecr batch-delete-image --repository-name ${PROJECT_NAME} --image-ids imageTag=$${line} --region ${DEPLOY_REGION}; \
			echo "Deleting image: $${line}"; \
		done; \
	fi
	
	@if [ -f ${FILE_IMAGES} ]; then \
		rm -rf ${FILE_IMAGES}; \
	fi

ecr.build.image.latest: ## Build image for deploy.: make ecr.build.image.latest
	@cd $(PROJECT_DIR) && \
	cp ../docker/latest/Dockerfile Dockerfile && \
	docker build \
		--build-arg IMAGE=${IMAGE} \
		-f Dockerfile \
		--no-cache \
		-t $(REGISTRY_ECR)/$(IMAGE_DEPLOY) . && \
	rm -f Dockerfile

ecr.push.image: ## Publish image in ECR.: make ecr.push.image
	docker push \
		$(REGISTRY_ECR)/$(IMAGE_DEPLOY)