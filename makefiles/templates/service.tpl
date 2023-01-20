{
    "cluster": "__CLUSTER__",
    "serviceName": "__SERVICE_NAME__",
    "taskDefinition": "__TASK_DEFINITION__",
    "loadBalancers": [
        {
            "targetGroupArn": "__TARGET_GROUP_ARN__",
            "containerName": "__CONTAINER_NAME__",
            "containerPort": 80
        }
    ],
    "desiredCount": 2,
    "launchType": "FARGATE",
    "platformVersion": "LATEST",
    "networkConfiguration": {
        "awsvpcConfiguration": {
            "subnets": __SUBNETS__,
            "securityGroups": [
                "__SECURITY_GROUP__"
            ],
            "assignPublicIp": "ENABLED"
        }
    }
}