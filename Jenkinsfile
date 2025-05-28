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
          git fetch --tags
          git checkout tags/${params.TAG}
        """
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          docker build -t ${IMAGE_URI}:${params.TAG} .
          docker tag ${IMAGE_URI}:${params.TAG} ${IMAGE_URI}:latest
        """
      }
    }

    stage('Authenticate & Push Docker Image') {
      steps {
        withAWS(credentials: 'awsid', region: "${AWS_REGION}") {
          sh """
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

            docker push ${IMAGE_URI}:${params.TAG}
            docker push ${IMAGE_URI}:latest
          """
        }
      }
    }

    stage('Deploy to Lambda') {
      steps {
        withAWS(credentials: 'awsid', region: "${AWS_REGION}") {
          sh """
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
