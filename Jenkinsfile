pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "108792016419"
        AWS_REGION = "ap-south-1"
        REPO_NAME = "public.ecr.aws/p7a8f7m8/randomquotegenerator-anil"
        IMAGE_TAG = "latest"
        // ✅ Full ECR URL constructed automatically
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"

        // ✅ Path to your Terraform folder inside repo (example: terraform, infra, tf/)
        TF_DIR = "REPLACE_WITH_TERRAFORM_FOLDER_NAME"
    }

    stages {

        stage('Checkout Code from GitHub') {
            steps {
                // ✅ This automatically fetches code from GitHub repo connected to Jenkins job
                checkout scm
            }
        }

        stage('Configure AWS Credentials') {
            steps {
                // ✅ Replace 'aws-creds' with your AWS Credential ID stored in Jenkins
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws_jenkins']]) {
                    echo "AWS Credentials Configured ✅"
                }
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    echo "Logging into AWS ECR..."
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t $REPO_NAME .
                    docker tag $REPO_NAME:$IMAGE_TAG $ECR_URL:$IMAGE_TAG
                '''
            }
        }

        stage('Push Docker Image to AWS ECR') {
            steps {
                sh '''
                    echo "Pushing image to ECR..."
                    docker push $ECR_URL:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy with Terraform (Lambda Deployment)') {
            steps {
                dir("$TF_DIR") {
                    sh '''
                        echo "Initializing Terraform..."
                        terraform init

                        echo "Applying Terraform Deployment..."
                        terraform apply -auto-approve
                    '''
                }
            }
        }
    }
}
