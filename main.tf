#########################################
# ✅ Replace your details here
#########################################

variable "aws_region" {
  default = "ap-south-1"   # e.g., us-east-1 or ap-south-1
}

variable "aws_account_id" {
  default = "108792016419"   # e.g., 123456789012
}

variable "repo_name" {
  default = "randomquotegenerator-anil"   # e.g., random-quote-app
}

#########################################
# ✅ Add your VPC + Subnets (required for security group)
#########################################

variable "vpc_id" {
  default = "vpc-0837fc4ce02f6b0e4"  # e.g., vpc-0ab12345cd6ef7890
}

variable "subnet_ids" {
  type    = list(string)
  default = [
    "subnet-0b3abb56365076500",   # e.g., subnet-0ab12cd34ef567890
    "subnet-0ac508171b9981c4b",
    "subnet-0a9976c362fdfbe1e"
  ]
}

#########################################
# ✅ Provider Configuration
#########################################

provider "aws" {
  region = var.aws_region
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
# ✅ Attach Basic Lambda Logging Policy
#########################################

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#########################################
# ✅ Security Group for Lambda in the VPC
#########################################

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_security_group"
  description = "Security group for Lambda"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]   # ✅ Allows Lambda to make API calls or access public internet if NAT is configured
  }
}

#########################################
# ✅ Lambda Function Using Docker Image From ECR
#########################################

resource "aws_lambda_function" "random_quote_lambda" {
  function_name = "random-quote-lambda"
  package_type  = "Image"

  image_uri     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.repo_name}:latest"

  memory_size   = 256
  timeout       = 30
  role          = aws_iam_role.lambda_execution_role.arn

  ########################################################
  # ✅ Assign VPC + Security Group to Lambda
  ########################################################
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

#########################################
# ✅ Output (Shows Lambda ARN)
#########################################

output "lambda_function_arn" {
  value = aws_lambda_function.random_quote_lambda.arn
}
