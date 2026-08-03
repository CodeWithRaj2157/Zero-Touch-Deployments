variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "environment" {
  description = "Deployment Environment"
  type        = string
}


variable "alarm_email" {

  description = "Email for CloudWatch Alerts"

  type = string

}


