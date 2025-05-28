pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'                       // Change your region
    ECR_REPO = 'node'                // ECR repo name
    AWS_ACCOUNT_ID = '298917544415'                // Your AWS Account ID
    IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    LAMBDA_FUNCTION_NAME = 'node'  // Lambda function name
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
        script {
          sh """
            docker build -t ${IMAGE_URI}:${params.TAG} . | \
            docker tag node:latest 298917544415.dkr.ecr.ap-south-1.amazonaws.com/node:latest
          """
        }
      }
    }
  /*
    stage('AWS Authentication') {
      steps {
        script {
          withAWS(credentials: 'awsid', region: "${AWS_REGION}") {
            echo "✅ AWS credentials loaded"
            sh "aws sts get-caller-identity"
          }
        }
      }
    }
*/
    stage('Authenticate with AWS ECR') {
      steps {
        script {
          sh """
            aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 298917544415.dkr.ecr.ap-south-1.amazonaws.com | \
            docker push 298917544415.dkr.ecr.ap-south-1.amazonaws.com/node:latest | \
              docker login --username AWS --password-stdin ${IMAGE_URI}
          """
        }
      }
    }

    stage('Push Docker Image to ECR') {
      steps {
        script {
          sh """
            docker push ${IMAGE_URI}:${params.TAG}
          """
        }
      }
    }

    stage('Deploy to Lambda') {
      steps {
        script {
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
 