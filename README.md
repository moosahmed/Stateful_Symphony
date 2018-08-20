# Stateful Symphony
This is the repo for my Insight Project for the July 2018 DevOps Engineering session 

## Table of Contents
1. [Introduction](README.md#introduction)
2. [Launch](README.md#launch)
3. [Pipeline](README.md#data-engineering-code-base-used-as-test-case)
4. [Platform](README.md#platform)
5. [Directory Structure](README.md#directory-structure)

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
Automate service deployments using Infrastructure and Container Orchestration.

The Approach focuses on three tenants:
1. IaC (Terraform)
2. Container (Kubernetes, Docker)

### IaC and Containerization
The use of an IaC orchestration tool such as `Terraform` in conjunction with `Docker` is sufficient enough for most configuration management(CM) needs that you do not need a specific CM tool[<sup>[2]</sup>](README.md#Refrences#2).

Docker will create an image that has all the software the server needs already installed and configured.
This image now needs a server to run it. This is where Terraform will orchestrate the servers and provision `Kubernetes` to deploy the Docker containers.

Benefits of this approach:
1. Mutable
  * Thus avoiding configuration drift.
2. Declarative 
  * Knowing history of changes in Infrastructure is not required
  * Reusable procedural code
3. Client Only Architecture
  * Limit failure modes of the infrastructure
  * Server architecture management is minimal

### Service Updates
Deploy updated services once set up. In particular stateful services that manage thier own schemas.
 1. How will we deploy updates which can include database schema updates?
   * Database pods will be part of stateful set with persistent volumes attached, when a DB pod is redeployed it reattaches to the persistent volumes, thus keeping state.
 2. Granular Deployment - Limit update scope to updating the frequently changed resources and not the infrequently changed resources.
   * Terraform will use `-target` functionality.
   * Limiting scope increases scalability. - Wouldn't re provision everything in an automated way.

## Launch
### Prerequisites

1. AWS account
    1. IAM should have permissions for all resources used within.
    2. Make sure to gitignore your terraform.tfvars before the step below.
    3. Make a terraform.tfvars and provide access_key = "your_aws_access_key_id" secret_key = "your_aws_secret_access_key". (The environemnt variables were not used because the aws keys are used in multiple places - not just for the provider.)
2. Install Terraform
3. aws-iam-authenticator : https://github.com/kubernetes-sigs/aws-iam-authenticator
4. Install kubectl

### One-Click
Once the above is set up, you can cd into the terraform directory and hit terraform apply. Your Services are deployed!

## Data Engineering Code Base [Used](github.com/CCInCharge/campsite-hot-or-not) as test case

![Used](https://raw.githubusercontent.com/moosahmed/Stateful_Symphony/master/images/pipe.png "Used")

## Platform

![Platform](https://raw.githubusercontent.com/moosahmed/Stateful_Symphony/master/images/platform.png "Platform")

## Directory Structure

![Structure](https://raw.githubusercontent.com/moosahmed/Stateful_Symphony/master/images/tree1.png "Structure")
![Structure](https://raw.githubusercontent.com/moosahmed/Stateful_Symphony/master/images/tree2.png "Structure")

## References
1. https://mesosphere.com/blog/stateful-services-black-sheep-container-world/
2. https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c
3. https://medium.com/build-acl/docker-deployments-using-terraform-d2bf36ec7bdf
4. https://medium.com/muhammet-arslan/kubernetes-cluster-on-aws-with-terraform-1-fdf9b6928ba6
