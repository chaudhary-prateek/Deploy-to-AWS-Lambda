/*
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

    stage('Authenticate AWS') {
      steps {
        withCredentials([[$class: 'UsernamePasswordMultiBinding',
                          credentialsId: 'AWS-ID',
                          usernameVariable: 'AWS_ACCESS_KEY_ID',
                          passwordVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            aws sts get-caller-identity --region $AWS_REGION
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          echo "🐳 Building Docker image: ${IMAGE_URI}:${params.TAG}"
          docker build -t ${IMAGE_URI}:${params.TAG} .
          docker tag ${IMAGE_URI}:${params.TAG} ${IMAGE_URI}:latest
        """
      }
    }

    stage('Authenticate & Push Docker Image') {
      steps {
        withCredentials([[$class: 'UsernamePasswordMultiBinding',
                          credentialsId: 'AWS-ID',
                          usernameVariable: 'AWS_ACCESS_KEY_ID',
                          passwordVariable: 'AWS_SECRET_ACCESS_KEY']]) {
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
        withCredentials([[$class: 'UsernamePasswordMultiBinding',
                          credentialsId: 'AWS-ID',
                          usernameVariable: 'AWS_ACCESS_KEY_ID',
                          passwordVariable: 'AWS_SECRET_ACCESS_KEY']]) {
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
*/

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
      description: 'Select the Git branch to use',
      branchFilter: 'origin/(.*)',             // Only matches origin/ branches
      useRepository: 'https://github.com/chaudhary-prateek/Deploy-to-AWS-Lambda.git',
      sortMode: 'DESCENDING',
      selectedValue: 'NONE',
      quickFilterEnabled: true
    )

    gitParameter(
      name: 'TAG',
      type: 'PT_TAG',
      defaultValue: '',
      description: 'Select Git tag (e.g., v1.0.0)',
      tagFilter: 'v.*',
      useRepository: 'https://github.com/chaudhary-prateek/Deploy-to-AWS-Lambda.git',
      sortMode: 'DESCENDING',
      selectedValue: 'NONE',
      quickFilterEnabled: true
    )
  }

  stages {
    stage('Checkout Code') {
      steps {
        script {
          echo "🌿 Branch: ${params.BRANCH}"
          echo "🏷️ Tag: ${params.TAG}"

          def repoUrl = 'https://github.com/chaudhary-prateek/Deploy-to-AWS-Lambda.git'

          if (params.TAG?.trim()) {
            echo "📥 Checking out tag: ${params.TAG}"
            checkout([$class: 'GitSCM',
              branches: [[name: "refs/tags/${params.TAG}"]],
              userRemoteConfigs: [[url: repoUrl]]
            ])
          } else if (params.BRANCH?.trim()) {
            echo "📥 Checking out branch: ${params.BRANCH}"
            checkout([$class: 'GitSCM',
              branches: [[name: "*/${params.BRANCH}"]], // this auto maps to "origin/main" correctly
              userRemoteConfigs: [[url: repoUrl]]
            ])
          } else {
            error("❌ No valid branch or tag selected.")
          }
        }
      }
    }

    stage('Inject AWS Credentials') {
      steps {
        withCredentials([[
          $class: 'UsernamePasswordMultiBinding',
          credentialsId: 'AWS-ID',
          usernameVariable: 'CREDS_ACCESS_KEY',
          passwordVariable: 'CREDS_SECRET_KEY'
        ]]) {
          script {
            env.AWS_ACCESS_KEY_ID = "${env.CREDS_ACCESS_KEY}"
            env.AWS_SECRET_ACCESS_KEY = "${env.CREDS_SECRET_KEY}"
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
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${IMAGE_URI}
            docker push ${IMAGE_URI}:${params.TAG}
          """
        }
      }
    }

    stage('Deploy to Lambda') {
      steps {
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
