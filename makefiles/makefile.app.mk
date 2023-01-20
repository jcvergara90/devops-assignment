.PHONY: app.up \
		app.down \
		app.logs

## TARGET ##

app.up: ## Executing the app.: make app.up
	@export IMAGE="$(IMAGE)" && \
	export WORKDIR="$(PROJECT_DIR)" && \
	export HTTP_HOST="$(HTTP_HOST)" && \
	export HTTP_PORT="$(HTTP_PORT)" && \
	export CONTAINER_NAME="$(PROJECT_NAME)" && \
	export AWS_DEFAULT_REGION="$(DEPLOY_REGION)" && \
	export AWS_PROFILE="$(AWS_PROFILE)" && \
	docker compose up ${target}

app.down: ## Stopping the app.: make app.down
	@export IMAGE="$(IMAGE)" && \
	export WORKDIR="$(PROJECT_DIR)" && \
	export HTTP_HOST="$(HTTP_HOST)" && \
	export HTTP_PORT="$(HTTP_PORT)" && \
	export CONTAINER_NAME="$(PROJECT_NAME)" && \
	export AWS_DEFAULT_REGION="$(DEPLOY_REGION)" && \
	export AWS_PROFILE="$(AWS_PROFILE)" && \
	docker compose down

app.logs: ## Executing the app.: make app.logs SERVICE=api
	@docker compose logs -f ${SERVICE}