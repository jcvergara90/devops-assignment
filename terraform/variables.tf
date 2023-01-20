
// Route 53 & ACM
variable "domain_name" {
  type        = string
  description = "Existing domain record already setup in route53"
  default     = "dev.perueduca.digital.otic.pe"
}

variable "route53_subdomain" {
  type        = string
  description = "subdomain name which API gateway will use for custom domain setup. Needs to match the ACM SSL"
  default     = "devops"
}

variable "domain_name_certificate_arn" {
  type        = string
  description = "The ACM certificate ARN to use for the api gateway"
  default     = "arn:aws:acm:us-east-2:793967978418:certificate/92ac2ea8-559b-4530-a4ee-9450623ffacb"
}



variable "region" {
  type    = string
  default = "us-east-2"
}

variable "name_prefix" {
  type        = string
  description = "name prefix to give to all recources in project"
  default = "lab"

}

variable "vpc_id" {
  type        = string
  description = "vpc id with 2 private subnets already existing"
  default     = "vpc-06acc9d64c2a5b527"
}

variable "command_args" {
  type        = list
  description = "docker container command arguments"
  default     = [" "]
}


variable "controller_task_role_arn" {
  type        = string
  description = "An custom task role to use for the jenkins controller (optional)"
  default     = null
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "An custom execution role to use as the ecs exection role (optional)"
  default     = null
}

variable "controller_port" {
  type    = number
  default = 80
}

variable "controller_cpu" {
  type    = number
  default = 2048
}

variable "controller_memory" {
  type    = number
  default = 4096
}

variable "default_tags" {
  default = {
    Terraform = "true"
    Project   = "devops"
  }
  description = "Additional resource tags"
  type        = map(string)
}

