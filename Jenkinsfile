pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "108792016419"
        AWS_REGION = "ap-south-1"

        REPO_NAME = "randomquotegenerator-anil"
        IMAGE_TAG = "latest"
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"

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

       stage('Login to ECR') {
    steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                          credentialsId: 'AWS-CREDS']]) {
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


        stage('Build Docker Image') {
            steps {
                bat """
                    echo 🐳 Building Docker Image...
                    docker build -t %REPO_NAME% .
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

        stage('Deploy with Terraform') {
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
