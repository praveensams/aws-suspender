variable "aws_account_id" {
}

variable "aws_access" {}

variable "aws_secret" {}

variable "status" {}

variable "account_id" {}

variable "aws_region" {
    default = "me-south-1"
}

variable "action" {}

variable "regions" {}

variable "SuspenderSchedule" {}

variable "lambda_sts" {
    default = "lambda.amazonaws.com"
}

variable "lambda_handler" {
  default = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
    default = "python3.8"
}

variable "lambda_timeout" {
    default = 60
}

variable "lambda_memory" {
    default = 128
}

variable "layer_name" {
  default = "slack-webhook-v2"
}

variable "lambda_function_name" {
    default = "ec2"
}

variable "cw_event_schedule" {
    default = "cron(30 3 * * ? *)"
}

variable "cw_event_name" {
    default = "cw-log-group-once-a-day"
}

variable "cw_event_description" {
    default = "Daily at 7:30 every day"
}

variable "cw_event_target_id" {
    default = "lambda-function"
}
