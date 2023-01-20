.PHONY: vpc.get \
		tg.get \
		tg.create


## TARGET ##
vpc.get:
	$(eval VPC_ID := $(shell aws ec2 describe-vpcs \
							  		--filters "Name=tag:Name,Values=${VPC_NAME_FILTER}" \
									--region ${DEPLOY_REGION} \
									| jq -r '.Vpcs[0].VpcId'))

tg.get:
	$(eval TARGET_GROUP_ARN := $(shell aws elbv2 describe-target-groups \
							  		--query 'TargetGroups[].{TargetGroupArn:TargetGroupArn,TargetGroupName:TargetGroupName}' \
									--region ${DEPLOY_REGION} \
									| jq -r '.[].TargetGroupArn' | grep ${PROJECT_NAME} ))

tg.create: vpc.get ## Create target group.: make tg.create
	aws elbv2 create-target-group \
		--name $(PROJECT_NAME)  \
		--protocol HTTP \
		--port  $(HTTP_PORT_TG) \
		--target-type ip \
		--health-check-path "$(HEALTH_CHECK_PATH)" \
		--vpc-id $(VPC_ID) \
		--region $(DEPLOY_REGION)

tg.update: tg.get ## Update target group.: make tg.update
	aws elbv2 modify-target-group \
		--target-group-arn  $(TARGET_GROUP_ARN)  \
		--health-check-port $(HTTP_PORT) \
		--region $(DEPLOY_REGION)
