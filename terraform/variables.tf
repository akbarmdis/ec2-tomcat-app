variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "tomcat-app"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "tomcat_version" {
  description = "Tomcat version to install"
  type        = string
  default     = "9.0.82"
}

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
}
