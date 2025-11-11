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
# ✅ Add your VPC + Subnets
#########################################

variable "vpc_id" {
  default = "vpc-0837fc4ce02f6b0e4"
}

variable "subnet_ids" {
  type    = list(string)
  default = [
    "subnet-0b3abb56365076500"
  ]
}

#########################################
# ✅ Provider
#########################################

provider "aws" {
  region = var.aws_region
}

#########################################
# ✅ IAM Role
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
# ✅ Lambda Security Group
#########################################

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_security_group"
  description = "Security group for Lambda"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#########################################
# ✅ Lambda Function (Docker Image)
#########################################

resource "aws_lambda_function" "random_quote_lambda" {
  function_name = "random-quote-lambda"
  package_type  = "Image"

  image_uri = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.repo_name}:latest"

  # ✅ REQUIRED to match your Docker build (--platform=linux/amd64)
  architectures = ["x86_64"]

  memory_size = 256
  timeout     = 30
  role        = aws_iam_role.lambda_execution_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

#########################################
# ✅ Output
#########################################

output "lambda_function_arn" {
  value = aws_lambda_function.random_quote_lambda.arn
}
