const fs = require("fs")

const serviceName = process.argv[2] + '-service'
const imageName = process.argv[3];

let task = {
    "containerDefinitions": [
        {
            "name": serviceName,
            "image": imageName,
            "cpu": 0,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "entryPoint": [],
            "command": [],
            "environment": [],
            "mountPoints": [],
            "volumesFrom": [],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/project-api",
                    "awslogs-region": "ap-south-1",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ],
    "family": "ca-3-service",
    "taskRoleArn": "arn:aws:iam::123166012761:role/ecsTaskExecutionRole",
    "executionRoleArn": "arn:aws:iam::123166012761:role/ecsTaskExecutionRole",
    "networkMode": "awsvpc",
    "volumes": [],
    "placementConstraints": [],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "2048",
    "runtimePlatform": {
        "operatingSystemFamily": "LINUX"
    }
}

let taskString = JSON.stringify(task)

fs.writeFile("pipelines/task-definition.json", taskString, 'utf8', function (err) {
    if (err) {
        console.log("Err !!");
        return console.log(err);
    }
    console.log("Task Defination (ECS) generated !!");
});
