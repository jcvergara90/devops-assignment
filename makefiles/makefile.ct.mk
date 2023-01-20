.PHONY: copy_requirements \
		ct.build.image \
		ct.cmd \
		ct.shell

## TARGET ##

copy_requirements:
	@cp $(PROJECT_DIR)/requirements.txt docker/dev/requirements.txt

ct.build.image: copy_requirements ## Build image for development: make ct.build.image
	@cd docker/dev && \
		docker build -f Dockerfile -t $(IMAGE) . --no-cache && \
		rm -if requirements.txt

ct.cmd:
	@docker run --rm -it \
		--name $(PROJECT_NAME) \
		-v $(PWD)/$(PROJECT_DIR):/$(PROJECT_DIR) \
		-v ~/.aws/config:/root/.aws/config \
		-v ~/.aws/credentials:/root/.aws/credentials \
		-w /$(PROJECT_DIR) \
		-e AWS_DEFAULT_REGION=${DEPLOY_REGION} \
		-e AWS_PROFILE=${AWS_PROFILE} \
		$(DAEMON) \
		$(PORT) \
		$(IMAGE) \
		$(COMMAND)

ct.shell: ## Connect to the container by shell.: make ct.shell
	@make ct.cmd COMMAND=sh
