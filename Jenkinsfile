pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = 'AKIAULGG7YHP3KIGE2NG'
        AWS_SECRET_ACCESS_KEY = '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'
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '298917544415'
        ECR_REPO = 'node'
        IMAGE_TAG = "latest"
        LAMBDA_FUNCTION_NAME = 'node'
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/chaudhary-prateek/Deploy-to-AWS-Lambda.git'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Docker Push to ECR') {
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 298917544415.dkr.ecr.ap-south-1.amazonaws.com
                    docker tag node:latest 298917544415.dkr.ecr.ap-south-1.amazonaws.com/node:latest
                    docker push 298917544415.dkr.ecr.ap-south-1.amazonaws.com/node:latest
                    """
                }
            }
        }

        stage('Deploy to Lambda') {
            steps {
                script {
                    sh """
                    aws lambda update-function-code \
                    --function-name $LAMBDA_FUNCTION_NAME \
                    --image-uri $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} \
                    --region $AWS_REGION
                    """
                }
            }
        }
    }
}
