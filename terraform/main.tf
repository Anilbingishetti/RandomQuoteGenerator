#########################################
# ✅ Replace your details here
#########################################

variable "aws_region" {
  default = "ap-south-1"
}

variable "aws_account_id" {
  default = "108792016419"
}

variable "repo_name" {
  default = "randomquotegenerator-anil"
}

#########################################
# ✅ Provider
#########################################

provider "aws" {
  region = var.aws_region
}

#########################################
# ✅ Automatically Detect Default VPC
#########################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#########################################
# ✅ IAM Role for Lambda Execution
#########################################

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role_random_quote"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#########################################
# ✅ IAM Policy for VPC Access
#########################################

resource "aws_iam_role_policy" "lambda_vpc_permissions" {
  name = "lambda_vpc_permissions"
  role = aws_iam_role.lambda_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

#########################################
# ✅ Attach Basic Lambda Logging Policy
#########################################

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#########################################
# ✅ Security Group for Lambda
#########################################

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_security_group"
  description = "Security group for Lambda function"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#########################################
# ✅ Lambda Function Using Docker Image
#########################################

resource "aws_lambda_function" "random_quote_lambda" {
  function_name = "random-quote-lambda"
  package_type  = "Image"

  image_uri = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.repo_name}:latest"

  architectures = ["x86_64"]   # ✅ Must match Docker build --platform

  memory_size = 256
  timeout     = 30
  role        = aws_iam_role.lambda_execution_role.arn

  vpc_config {
    subnet_ids         = data.aws_subnets.default_subnets.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

#########################################
# ✅ Output
#########################################

output "lambda_function_arn" {
  value = aws_lambda_function.random_quote_lambda.arn
}
