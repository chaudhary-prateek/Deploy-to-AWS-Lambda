pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'
    ECR_REPO = 'node'
    AWS_ACCOUNT_ID = '298917544415'
    IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    LAMBDA_FUNCTION_NAME = 'node'
  }

  parameters {
    string(name: 'BRANCH', defaultValue: 'main', description: 'Git branch to use')
    string(name: 'TAG', defaultValue: 'v1.0.0', description: 'Git tag to deploy')
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: "${params.BRANCH}", url: 'https://github.com/chaudhary-prateek/Deploy-to-AWS-Lambda.git'
        sh """
          echo "📥 Fetching tags and checking out tag: ${params.TAG}"
          git fetch --tags
          git checkout tags/${params.TAG}
        """
      }
    }
/*
    stage('Build Docker Image') {
      steps {
        sh """
          echo "🐳 Building Docker image: ${IMAGE_URI}:${params.TAG}"
          docker build -t ${IMAGE_URI}:${params.TAG} .
          docker tag ${IMAGE_URI}:${params.TAG} ${IMAGE_URI}:latest
        """
      }
    }
*/
    stage('Authenticate & Push Docker Image') {
      steps {
        withAWS(credentials: 'awsid', region: "${AWS_REGION}") {
          sh """
            echo "🔐 Logging into ECR..."
            aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 298917544415.dkr.ecr.ap-south-1.amazonaws.com

            echo "📤 Pushing Docker image: ${IMAGE_URI}:${params.TAG}"
            docker tag node:latest 298917544415.dkr.ecr.ap-south-1.amazonaws.com/node:latest

            echo "📤 Pushing Docker image: ${IMAGE_URI}:latest"
            docker push 298917544415.dkr.ecr.ap-south-1.amazonaws.com/node:latest
          """
        }
      }
    }

    stage('Deploy to Lambda') {
      steps {
        withAWS(credentials: 'awsid', region: "${AWS_REGION}") {
          sh """
            echo "🚀 Deploying to Lambda function: ${LAMBDA_FUNCTION_NAME}"
            aws lambda update-function-code \
              --function-name ${LAMBDA_FUNCTION_NAME} \
              --image-uri ${IMAGE_URI}:${params.TAG} \
              --region ${AWS_REGION}
          """
        }
      }
    }
  }
}
