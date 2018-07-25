# Insight DevOps Project
This is the repo for my Insight Project for the July 2018 DevOps Engineering session 

## Table of Contents
1. [Puzzle description](README.md#project-idea)

## Project Idea
The idea focuses on three tenants:
1. IaC (Terraform)
2. Container (AWS ECS, Docker)
3. CI/CD (Jenkins (blue - green deployment))

The use of an IaC orchestration tool such as `Terraform` in conjuction with `Docker` is sufficient enough for most conifguration mangagement(CM) needs that you do not need a specific CM tool[<sup>[1]</sup>](README.md#Refrences#1).

Docker will create an image that has all the software the server needs already installed and configured.
This image now needs a server to run it. This is where Terraform will provision a bunch of servers on `AWS ECS` and deploy the Docker containers.

Benefits of this approach:
1. Mutable
  *Thus avoiding configuration drift.
2. Declarative 
  *Knowing history of changes in Infrastructure is not required
  *Reusable procedural code
3. Client Only Architecture
  *Limit failure modes of the infrastructure
  *Server architecture management is minimal


## References
1. https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c
