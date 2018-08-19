variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "k8s_cluster" {
  description = "Kubernetes cluster to deploy; must be unique"
  type        = "string"
}

variable "s3_bucket_url" {
  description = "Must be a globally unique bucket name across aws"
  default = "s3a://s.k8s.state/"
}

variable "access_key" {
  description = "In `terraform.tfvars` file: access_key = 'your_aws_access_key_id'. Make sure to gitignore your tfvars file"
}

variable "secret_key" {
  description = "In `terraform.tfvars` file: access_key = 'your_aws_secret_access_key'. Make sure to gitignore your tfvars file"
}