terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "praveensam-com"

    workspaces {
      prefix = "praveensam-cloudwatch-"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}

resource "aws_iam_role" "aws_cloudwatch_log-group_role" {
  name = format("aws-lambda-ec2-role-%s", var.action)
  assume_role_policy = templatefile("role-permissions-sts.tpl", { LAMBDA = var.lambda_sts } )
}

resource "aws_iam_policy" "aws_cloudwatch_log-group_policy" {
  name = format("aws-lambda-ec2-policy-%s", var.action)
  description = "AWS access keys rotate lambda execution policy"
  policy = templatefile("role-permissions-policy.tpl", { AWS = var.aws_account_id, LAMBDA = var.lambda_function_name} )
}

resource "aws_iam_role_policy_attachment" "attach-policy" {
  role       = aws_iam_role.aws_cloudwatch_log-group_role.name
  policy_arn = aws_iam_policy.aws_cloudwatch_log-group_policy.arn
}

data "archive_file" "lambda-archive" {
  type        = "zip"
  source_dir = "code/package"
  output_path = "ec2-stop-instance.zip"
}

resource "aws_lambda_function" "lambda-function" {
  filename         = "ec2-stop-instance.zip"
  function_name    = format("%s-%s", var.lambda_function_name,var.action)
  role             = aws_iam_role.aws_cloudwatch_log-group_role.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory
  environment {
    variables = {
      regions = var.regions
      aws_access = var.aws_access
      aws_secret = var.aws_secret
      status = var.status
      SuspenderSchedule = var.SuspenderSchedule
      cw_event_schedule = var.cw_event_schedule
      account_id = var.account_id
    }
  }
}

resource "aws_cloudwatch_event_rule" "once_a_day" {
  name                = format("%s-%s", var.lambda_function_name,var.action)
  description         = var.cw_event_description
  schedule_expression = var.cw_event_schedule
}

resource "aws_cloudwatch_event_target" "check_cw_alarm_once_a_day" {
  rule      = aws_cloudwatch_event_rule.once_a_day.name
  target_id = var.cw_event_target_id
  arn       = aws_lambda_function.lambda-function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_aws_access_keys" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-function.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.once_a_day.arn
}
