# Insight DevOps Project
This is the repo for my Insight Project for the July 2018 DevOps Engineering session 

## Table of Contents
1. [Introduction](README.md#introduction)

## Introduction

Automate Infrastructure using Infrastructure as Code (IaC) Orchestration and Containerization. Use Jenkins to Implement Continous Integration/Continous Deployment(CI/CD) with a focus on blue - green deployment (maybe pre-build branch merging?). 

The idea focuses on three tenants:
1. IaC (Terraform)
2. Container (Docker, AWS ECS)
3. CI/CD (Jenkins (blue - green deployment))

### IaC and Containerization
The use of an IaC orchestration tool such as `Terraform` in conjuction with `Docker` is sufficient enough for most conifguration mangagement(CM) needs that you do not need a specific CM tool[<sup>[1]</sup>](README.md#Refrences#1).

Docker will create an image that has all the software the server needs already installed and configured.
This image now needs a server to run it. This is where Terraform will provision a bunch of servers on `AWS ECS` and deploy the Docker containers.

Benefits of this approach:
1. Mutable
  * Thus avoiding configuration drift.
2. Declarative 
  * Knowing history of changes in Infrastructure is not required
  * Reusable procedural code
3. Client Only Architecture
  * Limit failure modes of the infrastructure
  * Server architecture management is minimal

### CI/CD
As part of a CI/CD pipeline deploy updated Docker images for the services once set up. In particular stateful services that manage thier own schemas.
 1. How will we deploy updates which can include databse schema updates?
   a. Define new containers to be deployed
   b. Update database schema which will depend on new container definitions.
   c. Deploy new containers and update ECS using the updated database schema
 2. Granular Deployment - Limit CD's scope to updating the frequently changed resources and not the infrequently changed resources.
   a. CD can have set of permissions
   b. Terraform will use `-target` functionality.
   c. Limiting scope increases scalability. - wouldnt `terraform apply` everything in an automated way.
 3. How can we achieve this while maintaining blue-green deployment
 4. Jenkins will be used instead of AWS CodePipeline to avoid vendor lock-in


### Stretch Goals
1. Using Kubernetes, manage multiple pipelines with dependencies
2. Some Monitoring/Observability


## References
1. https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c
2. https://medium.com/build-acl/docker-deployments-using-terraform-d2bf36ec7bdf
