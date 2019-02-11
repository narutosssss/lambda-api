locals {
  handler     = "${var.handler}"
  runtime     = "${var.runtime}"
  name        = "${var.name}"
  role_name   = "${var.role_name}"
  timeout     = "${var.timeout}"
  source_dir  = "${var.source_dir}"
  output_path = "${var.output_path}"
  environment = "${var.environment}"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${local.source_dir}"
  output_path = "${local.output_path}"

  # source_dir  = "https://github.com/narutosssss/modules-lambda/blob/master/lambda.zip"
  # output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  # filename          = "${data.archive_file.lambda.output_path}"
  # function_name     = "${var.name}"
  filename = "${local.output_path}"

  function_name    = "${local.name}"
  role             = "${var.role_name}"
  handler          = "${local.handler}"
  runtime          = "${local.runtime}"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda.output_path}"))}"
  timeout          = "${local.timeout}"
  publish          = true

  environment {
    variables = "${local.environment}"
  }

  tags = "${var.tags}"
}

resource "aws_lambda_function_permission" "lambda" {
  function_name = "${aws_lambda_function.lambda.function_name}"
  qualifier     = "${aws_lambda_function.lambda.version}"
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  function_name = "${aws_lambda_function.lambda.arn}" //
}

resource "aws_lambda_alias" "test_alias" {
  name             = "testalias"
  function_name    = "${aws_lambda_function.lambda.function_name}"
  function_version = "${aws_lambda_function.lambda.version}"
}
