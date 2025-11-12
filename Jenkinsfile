pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "108792016419"
        AWS_REGION = "ap-south-1"
        REPO_NAME = "randomquotegenerator-anil"
        IMAGE_TAG = "latest"
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
        LAMBDA_NAME = "random-quote-lambda"
        TF_DIR = "terraform"
    }

    stages {

        stage('Checkout Code from GitHub') {
            steps {
                checkout scm
            }
        }

        stage('Configure AWS Credentials') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS-CREDS']]) {
                    echo "✅ AWS Credentials Configured"
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS-CREDS']]) {
                    bat """
                        echo 🔐 Logging into AWS ECR...
                        aws configure set aws_access_key_id %AWS_ACCESS_KEY_ID%
                        aws configure set aws_secret_access_key %AWS_SECRET_ACCESS_KEY%
                        aws configure set default.region %AWS_REGION%
                        aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_URL%
                    """
                }
            }
        }

        stage('Cleanup Old Lambda & ECR Image') {
            steps {
                bat """
                    echo 🧹 Cleaning up old Lambda and ECR image...

                    REM ✅ Delete existing Lambda function (ignore errors if not found)
                    aws lambda delete-function --function-name %LAMBDA_NAME% --region %AWS_REGION% || echo "⚠️ No old Lambda found"

                    REM ✅ Delete old image from ECR (ignore if not found)
                    aws ecr batch-delete-image --repository-name %REPO_NAME% --image-ids imageTag=%IMAGE_TAG% --region %AWS_REGION% || echo "⚠️ No old image found"

                    REM ✅ (Optional) Delete old ECR repo completely — uncomment if you want to recreate it
                    REM aws ecr delete-repository --repository-name %REPO_NAME% --region %AWS_REGION% --force || echo "⚠️ No old repo found"
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                    echo 🐳 Building Docker Image...
                    set DOCKER_BUILDKIT=0
                    docker build --platform linux/amd64 -t %REPO_NAME% .
                    docker tag %REPO_NAME%:%IMAGE_TAG% %ECR_URL%:%IMAGE_TAG%
                """
            }
        }

        stage('Push Docker Image to AWS ECR') {
            steps {
                bat """
                    echo 📦 Pushing Docker Image to ECR...
                    docker push %ECR_URL%:%IMAGE_TAG%
                """
            }
        }

        stage('Deploy Lambda with Terraform') {
            steps {
                dir("${TF_DIR}") {
                    bat """
                        echo 🚀 Initializing Terraform...
                        terraform init

                        echo 🚀 Applying Terraform Deployment...
                        terraform apply -auto-approve
                    """
                }
            }
        }
    }
}
