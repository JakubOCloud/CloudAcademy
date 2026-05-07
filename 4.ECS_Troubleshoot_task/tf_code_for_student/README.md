# TODO

- configure autoscaling to target tracking
- fix security groups
- maybe add another nat gateway to second AZ
- role iam?
- image is not on ecr?
- alb does not have target group

# Fixed

## 10_security_groups

- Added ingress for port 80 from anywhere in alb sg
- Added ingress for allowing trafic from alb on container port

## 11_alb

- Added target group with health checks

## 12_ecs

- added data source for execution role
- deleted task role because its not needed
- added for tests:
  {
  "name" : "cpu-stressor",
  "image" : "alexeiled/stress-ng:latest",
  "command" : ["--cpu", "1", "--cpu-load", "80", "--timeout", "300s"],
  "essential" : false,
  "memoryReservation" : 50
  }

## 13_autoscaling

- Added policy for target tracking and used already existing variable
- For Testing purposes I added 2nd container in task definitions which is supposed to stress test cpu

# Possible changes

- adding NAT to second AZ
- holding your code in repo with pipelines which automatically build and push your image
- remote state with lock
- remove hard coded aws profile
- use of modules
- adding more cloudwatch alarms and dashboard which tracks this service
- maybe some sns notifications
- maybe add second autoscaler which tracks memory?
