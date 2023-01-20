{
    "family": "__FAMILY__",
    "networkMode": "awsvpc",
    "taskRoleArn": "__TASK_ROLE_ARN__",
    "executionRoleArn": "__EXECUTION_ROLE_ARN__",
    "containerDefinitions": [
        {
            "name": "__CONTAINER_NAME__",
            "image": "__CONTAINER_IMAGE_NAME__",
            "environment": [
                __ENVIRONMENT__
            ],
            "portMappings": [
                {
                    "containerPort": __CONTAINER_PORT__,
                    "hostPort": __HOST_PORT__,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "__AWSLOGS_GROUP__",
                    "awslogs-region": "__AWSLOGS_REGION__",
                    "awslogs-create-group": "true",
                    "awslogs-stream-prefix": "__AWSLOGS_STREAM_PREFIX__"
                }
            }
        }
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "__CPU__",
    "memory": "__MEMORY__"
}