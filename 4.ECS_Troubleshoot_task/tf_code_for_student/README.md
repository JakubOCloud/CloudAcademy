# TODO

- configure autoscaling to target tracking
- fix security groups
- fix route tables
- maybe add another nat gateway to second AZ
- fix load balancer
- role iam?
- service does not have image attached
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

# Possible changes

- adding NAT to second AZ
- holding your code in repo with pipelines which automatically build and push your image
-
