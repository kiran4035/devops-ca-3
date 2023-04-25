#!/bin/bash

export ECS_CLUSTER="devops-ca3-cluster-2t4fwe"
export PROJECT_NAME="ca-3"
export ECS_SERVICE="$PROJECT_NAME"

curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install nodejs jq -y

source .env

node pipeline/taskGen.js "$PROJECT_NAME" "$IMAGE_URI"

awsTaskDfARN=$(aws ecs register-task-definition --cli-input-json file://pipelines/task-definition.json)
echo "$awsTaskDfARN"
awsTaskDfARN=$(echo "$awsTaskDfARN" | jq -r '.taskDefinition.taskDefinitionArn')
echo "$awsTaskDfARN"

checkIfServiceAlreadyExists=$(aws ecs describe-services --cluster $ECS_CLUSTER --services "$ECS_SERVICE-service")
echo "$checkIfServiceAlreadyExists"
checkIfServiceAlreadyExists=$(echo "$checkIfServiceAlreadyExists" | jq -r '.services[0].serviceArn')
echo "$checkIfServiceAlreadyExists"

if [ "$checkIfServiceAlreadyExists" == "null" ]; then
  echo "Service does not exist, creating service"
  aws elbv2 create-load-balancer --name "$PROJECT_NAME-lb" --subnets subnet-0fc65542d30359163 subnet-0926884c7d4e49572 --security-groups sg-0201d44e5c22789f6
  loadbalancerArn=$(aws elbv2 describe-load-balancers --names "$PROJECT_NAME-lb" | jq -r '.LoadBalancers[0].LoadBalancerArn')
  echo "$loadbalancerArn"
  aws elbv2 create-target-group --name "$PROJECT_NAME-tg" --protocol HTTP --port 80 --vpc-id vpc-022bb817b4132a309 --ip-address-type ipv4 --target-type ip --health-check-protocol HTTP --health-check-path /health --health-check-interval-seconds 10 --health-check-timeout-seconds 5 --healthy-threshold-count 2 --unhealthy-threshold-count 2
  targetGroupArn=$(aws elbv2 describe-target-groups --names "$PROJECT_NAME-tg" | jq -r '.TargetGroups[0].TargetGroupArn')
  echo "$targetGroupArn"
  aws elbv2 create-listener --load-balancer-arn "$loadbalancerArn" --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$targetGroupArn
  
  aws ecs create-service --cluster $ECS_CLUSTER --service-name "$ECS_SERVICE-service" --task-definition "$awsTaskDfARN" --desired-count 1 --launch-type FARGATE --network-configuration "awsvp
cConfiguration={subnets=[subnet-0fc65542d30359163],securityGroups=[sg-0201d44e5c22789f6]}" --load-balancers "targetGroupArn=$targetGroupArn,containerName=$ECS_SERVICE-service,containerPort=8
0"
  
  aws elbv2 describe-load-balancers --names "$PROJECT_NAME-lb"
  
  elbaddressArn=$(aws elbv2 describe-load-balancers --names "$PROJECT_NAME-lb" | jq -r '.LoadBalancers[0].LoadBalancerArn')
  loadbalancerListenerArn=$(aws elbv2 describe-listeners --load-balancer-arn "$elbaddressArn" | jq -r '.Listeners[0].ListenerArn')
  if [ "$loadbalancerListenerArn" == "null" ]; then
    echo "Listener does not exist, creating listener"
    aws elbv2 create-listener --load-balancer-arn "$elbaddressArn" --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$targetGroupArn
  fi
else
  echo "Service already exists, updating service"
  TASK_RUNNING_ID=$(aws ecs list-tasks --cluster $ECS_CLUSTER --service "$ECS_SERVICE-service"  | jq -r ".taskArns[0]")
  aws ecs update-service --cluster $ECS_CLUSTER --service "$ECS_SERVICE-service" --task-definition "$awsTaskDfARN" --desired-count 1 
  aws ecs stop-task --cluster $ECS_CLUSTER --task "$TASK_RUNNING_ID"
fi