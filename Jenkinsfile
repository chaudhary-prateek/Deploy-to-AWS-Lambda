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
    gitParameter(
      name: 'BRANCH',
      type: 'PT_BRANCH',
      defaultValue: 'main',
      branchFilter: '.*',
      useRepository: 'https://github.com/chaudhary-prateek/Deploy-to-AWS-Lambda.git',
      sortMode: 'DESCENDING'
    )
    string(name: 'TAG', defaultValue: '', description: 'Tag to deploy (populated dynamically via Active Choices)')
  }

  stages {
    stage('Checkout Code') {
      steps {
        script {
          echo "Selected BRANCH: '${params.BRANCH}'"
          echo "Selected TAG: '${params.TAG}'"

          if (params.TAG?.trim()) {
            echo "🔁 Checking out tag: ${params.TAG}"
            checkout([$class: 'GitSCM',
              branches: [[name: "refs/tags/${params.TAG}"]],
              userRemoteConfigs: [[url: 'https://github.com/chaudhary-prateek/Deploy-to-AWS-Lambda.git']]
            ])
          } else if (params.BRANCH?.trim()) {
            echo "🔁 Checking out branch: ${params.BRANCH}"
            checkout([$class: 'GitSCM',
              branches: [[name: "refs/heads/${params.BRANCH}"]],
              userRemoteConfigs: [[url: 'https://github.com/chaudhary-prateek/Deploy-to-AWS-Lambda.git']]
            ])
          } else {
            error("❌ No branch or tag specified")
          }
        }
      }
    }

    stage('Authenticate AWS') {
      steps {
        sh 'aws sts get-caller-identity --region $AWS_REGION'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          echo "🐳 Building Docker image: ${IMAGE_URI}:${params.TAG}"
          docker build -t ${IMAGE_URI}:${params.TAG} .
          docker images | grep ${ECR_REPO}
          docker tag ${IMAGE_URI}:${params.TAG} ${IMAGE_URI}:${params.TAG}
        """
      }
    }

    stage('Authenticate & Push Docker Image') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'awsid'
        ]]) {
          sh """
            echo "🔐 Logging into ECR..."
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

            echo "📤 Pushing Docker image: ${IMAGE_URI}:${params.TAG}"
            docker push ${IMAGE_URI}:${params.TAG}
          """
        }
      }
    }

    stage('Deploy to Lambda') {
      steps {
        sh """
          echo "🚀 Deploying Docker image to Lambda: ${LAMBDA_FUNCTION_NAME}"
          aws lambda update-function-code \
            --function-name ${LAMBDA_FUNCTION_NAME} \
            --image-uri ${IMAGE_URI}:${params.TAG} \
            --region ${AWS_REGION}
        """
      }
    }
  }
}
