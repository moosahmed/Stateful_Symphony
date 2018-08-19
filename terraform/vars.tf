variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "k8s_cluster" {
  description = "Kubernetes cluster to deploy"
  default     = "ek8s-cluster"
  type        = "string"
}

variable "s3_bucket_url" {
  description = "Must be a globally unique bucket name across aws"
  default = "s3a://s.k8s.state/"
}

//variable "access_key" {
//  description = "aws_access_key_id to be set in .tfvars file"
//}
//
//variable "secret_key" {
//  description = "aws_seceret_access_key to be set in .tfvars file"
//}