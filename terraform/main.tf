terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

/* Package Lambda from /src */
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../src/main.py"
  output_path = "${path.module}/lambda.zip"
}

/* Lambda Function */
resource "aws_lambda_function" "tree_lambda" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout      = 30
  memory_size = 256
}

/* IAM Execution Role */
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

/* CloudWatch Logging */
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
