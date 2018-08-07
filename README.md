# Stateful Symphony
This is the repo for my Insight Project for the July 2018 DevOps Engineering session 

## Table of Contents
1. [Introduction](README.md#introduction)

## Introduction
Everyone from small startups to large enterprises are adopting containers.

Containers offer:
 1. Increased Developer Agility
 2. Ability to move services across data centers
 3. Elasticity of services (scale up and scale out)
 4. High availability

### Stateless vs Stateful workload
Stateless applications don't "store" data. When a contianer, containing a stateless application redeploys, anything stored is lost. Stateful applications (i.e. Postgres) are services that require backing storage and keeping "state" is critical to running that service. So when a continer is updated and re-deployed we dont want data to be lost.

Organizations isolate stateless workloads in containers from thier stateful workloads(e.g. Data Services). This adds complexity and challenges. In the age of data-driven, microservice-based apps, managing these systems on single platform is of high value.[<sup>[1]</sup>](README.md#Refrences#1)

This solution will be able to handle updates to your service stack(including stateful workloads) residing in contianers with continuous delivery. Terraform will be used in the "Deploy" step to deploy the latest Docker image built in the "Build" step with zero-downtime, in an automated fashion, even if the new image requires a schema update of your stateful service.

## Plan of Action
Automate Infrastructure using Infrastructure as Code (IaC) Orchestration and Containerization. Use Jenkins to Implement Continous Integration/Continous Deployment(CI/CD) with a focus on blue - green deployment. 

The Approach focuses on three tenants:
1. IaC (Terraform)
2. Container (Kubernetes, Docker)
3. CI/CD (Jenkins (blue - green deployment))

### IaC and Containerization
The use of an IaC orchestration tool such as `Terraform` in conjunction with `Docker` is sufficient enough for most configuration management(CM) needs that you do not need a specific CM tool[<sup>[2]</sup>](README.md#Refrences#2).

Docker will create an image that has all the software the server needs already installed and configured.
This image now needs a server to run it. This is where Terraform will provision a bunch of EC2 servers and provision Kubernetes to deploy the Docker containers.

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
   * Define new containers to be deployed
   * Update database schema which will depend on new container definitions.
   * Deploy new containers and update Kubernetes using the updated database schema
 2. Granular Deployment - Limit CD's scope to updating the frequently changed resources and not the infrequently changed resources.
   * CD can have set of permissions
   * Terraform will use `-target` functionality.
   * Limiting scope increases scalability. - wouldnt `terraform apply` everything in an automated way.
 3. How can we achieve this while maintaining blue-green deployment
 4. Jenkins will be used instead of AWS CodePipeline to avoid vendor lock-in

### Stretch Goals
1. Test impact of Docker update and roll back to a previous version
2. Some Monitoring/Observability

## Prerequisites

1. AWS account - credentials set up properly (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY should be in your .profile)
2. Terraform
3. aws-iam-authenticator : https://github.com/kubernetes-sigs/aws-iam-authenticator

## References
1. https://mesosphere.com/blog/stateful-services-black-sheep-container-world/
2. https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c
3. https://medium.com/build-acl/docker-deployments-using-terraform-d2bf36ec7bdf
4. https://medium.com/muhammet-arslan/kubernetes-cluster-on-aws-with-terraform-1-fdf9b6928ba6
