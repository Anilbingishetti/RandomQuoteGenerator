pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "108792016419"
        AWS_REGION = "ap-south-1"
<<<<<<< HEAD
        REPO_NAME = "public.ecr.aws/p7a8f7m8/randomquotegenerator-anil"
        IMAGE_TAG = "latest"
        // ✅ Full ECR URL constructed automatically
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"

        // ✅ Path to your Terraform folder inside repo (example: terraform, infra, tf/)
        TF_DIR = "REPLACE_WITH_TERRAFORM_FOLDER_NAME"
=======

        REPO_NAME = "randomquotegenerator-anil"
        IMAGE_TAG = "latest"
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"

        TF_DIR = "terraform"
>>>>>>> 3ee16dd (comming from new folder)
    }

    stages {

        stage('Checkout Code from GitHub') {
            steps {
<<<<<<< HEAD
                // ✅ This automatically fetches code from GitHub repo connected to Jenkins job
=======
>>>>>>> 3ee16dd (comming from new folder)
                checkout scm
            }
        }

        stage('Configure AWS Credentials') {
            steps {
<<<<<<< HEAD
                // ✅ Replace 'aws-creds' with your AWS Credential ID stored in Jenkins
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws_jenkins']]) {
                    echo "AWS Credentials Configured ✅"
=======
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws_jenkins']]) {
                    echo "AWS Credentials Set ✅"
>>>>>>> 3ee16dd (comming from new folder)
                }
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
<<<<<<< HEAD
                    echo "Logging into AWS ECR..."
=======
>>>>>>> 3ee16dd (comming from new folder)
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
<<<<<<< HEAD
                    echo "Building Docker image..."
=======
>>>>>>> 3ee16dd (comming from new folder)
                    docker build -t $REPO_NAME .
                    docker tag $REPO_NAME:$IMAGE_TAG $ECR_URL:$IMAGE_TAG
                '''
            }
        }

        stage('Push Docker Image to AWS ECR') {
            steps {
                sh '''
<<<<<<< HEAD
                    echo "Pushing image to ECR..."
=======
>>>>>>> 3ee16dd (comming from new folder)
                    docker push $ECR_URL:$IMAGE_TAG
                '''
            }
        }

<<<<<<< HEAD
        stage('Deploy with Terraform (Lambda Deployment)') {
            steps {
                dir("$TF_DIR") {
                    sh '''
                        echo "Initializing Terraform..."
                        terraform init

                        echo "Applying Terraform Deployment..."
=======
        stage('Deploy with Terraform') {
            steps {
                dir("$TF_DIR") {
                    sh '''
                        terraform init
>>>>>>> 3ee16dd (comming from new folder)
                        terraform apply -auto-approve
                    '''
                }
            }
        }
    }
}
