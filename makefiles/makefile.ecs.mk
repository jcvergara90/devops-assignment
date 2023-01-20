.PHONY: create.task.def.file \
		create.service.file \
		ecs.register.task.definition \
		ecs.create.service \
		ecs.update.service \
		ecs.delete.service


## TARGET ##
create.service.file: security.group.get subnets.get tg.get
	$(shell \
			cat $(PWD)/makefiles/templates/service.tpl | \
			sed 's/__CLUSTER__/$(ECS_CLUSTER)/g' | \
			sed 's/__SERVICE_NAME__/$(PROJECT_NAME)/g' | \
			sed 's/__TASK_DEFINITION__/$(PROJECT_NAME)/g' | \
			sed 's#__TARGET_GROUP_ARN__#$(TARGET_GROUP_ARN)#g' | \
			sed 's/__CONTAINER_NAME__/$(PROJECT_NAME)/g' | \
			sed 's/__SUBNETS__/$(SUBNETS)/g' | \
			sed 's/__SECURITY_GROUP__/$(SECURITY_GROUP)/g' \
			>  $(PWD)/service.json)


environment.task.def: db.get.url ecr.get.build.version
	$(eval ENVIRONMENT_TASK_DEF := $(shell \
			cat $(PWD)/makefiles/templates/environment.tpl | \
			sed 's#__BUILD_VERSION__#${BUILD_VERSION}#g'))

create.task.def.file: ecr.last.image.get iam.role.get environment.task.def
	$(shell \
			cat $(PWD)/makefiles/templates/task_definition.tpl | \
			sed 's/__FAMILY__/$(PROJECT_NAME)/g' | \
			sed 's#__TASK_ROLE_ARN__#$(ROLE_ARN)#g' | \
			sed 's#__EXECUTION_ROLE_ARN__#$(ROLE_ARN)#g' | \
			sed 's#__CONTAINER_NAME__#$(PROJECT_NAME)#g' | \
			sed 's#__CONTAINER_IMAGE_NAME__#$(REGISTRY_ECR)/$(ECR_IMAGE_LATEST)#g' | \
			sed 's/__CONTAINER_PORT__/$(CONTAINER_PORT)/g' | \
			sed 's#__ENVIRONMENT__#$(ENVIRONMENT_TASK_DEF)#g' | \
			sed 's/__HOST_PORT__/$(HOST_PORT)/g' | \
			sed 's/__AWSLOGS_GROUP__/$(PROJECT_NAME)/g' | \
			sed 's/__AWSLOGS_REGION__/$(DEPLOY_REGION)/g' | \
			sed 's/__AWSLOGS_STREAM_PREFIX__/$(OWNER)/g' | \
			sed 's/__CPU__/$(CONTAINER_CPU)/g' | \
			sed 's/__MEMORY__/$(CONTAINER_MEMORY)/g' \
			>  $(PWD)/task_definition.json)

security.group.get:
	$(eval SECURITY_GROUP := $(shell aws ec2 describe-security-groups\
    							--filters "Name=group-name,Values=*${SECURITY_GROUP_NAME_FILTER}" \
								--query "SecurityGroups[*].{Name:GroupName,ID:GroupId}" \
								--region ${DEPLOY_REGION} \
								| jq -r .[].ID))

subnets.get:
	$(eval SUBNETS := $(shell aws ec2 describe-subnets \
    							--filters "Name=tag:Name,Values=${SUBNETS_NAME_FILTER}" \
								--region ${DEPLOY_REGION} \
								| jq -r '.Subnets | map(.SubnetId)'))

iam.role.get:
	$(eval ROLE_ARN := $(shell aws iam get-role \
									--role-name ${OWNER}-role \
									| jq -r '.Role.Arn' ))
ecs.service.name:
	$(eval ECS_SERVICE_NAME := $(shell aws ecs describe-services \
		--cluster ${ECS_CLUSTER} \
		--services ${PROJECT_NAME} \
		--region ${DEPLOY_REGION} | jq -r '.services[0].serviceName'))

ecs.register.task.def: create.task.def.file ## Register task definition.: make ecs.register.task.def
	@aws ecs \
		register-task-definition --cli-input-json file://${PWD}/task_definition.json \
		--region ${DEPLOY_REGION}
	@rm -f ${PWD}/task_definition.json

ecs.deploy.service: ecs.service.name ## Deploy service.: make ecs.deploy.service
	@if [ "${ECS_SERVICE_NAME}" != "${PROJECT_NAME}" ]; then \
		make ecs.create.service; \
	else \
		make ecs.update.service; \
	fi

ecs.create.service: create.service.file ## Create service.: make ecs.create.service
	@aws ecs create-service \
		--cli-input-json file://${PWD}/service.json \
		--region ${DEPLOY_REGION}
	@rm -f ${PWD}/service.json

ecs.update.service:  ## Update service.: make ecs.update.service
	@aws ecs update-service \
		--cluster ${ECS_CLUSTER} \
		--service ${PROJECT_NAME} \
		--desired-count ${DESIRED_COUNT} \
		--task-definition ${PROJECT_NAME} \
		--region ${DEPLOY_REGION}

ecs.delete.service: ## Delete service.: make ecs.delete.service
	@aws ecs delete-service \
		--cluster ${ECS_CLUSTER} \
		--service ${PROJECT_NAME} \
		--region ${DEPLOY_REGION}
