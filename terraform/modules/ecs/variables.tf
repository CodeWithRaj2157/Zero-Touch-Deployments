variable "environment" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "repository_url" {
  type = string
}


variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "container_port" {
  type = number
}

variable "task_role_arn" {
  type = string
}

variable "desired_count" {
  type = number
}


