pipeline {
  agent any

  environment {
    AWS_REGION   = 'ap-south-1'      // Change to your region
    AWS_ACCOUNT_ID = '12345678'      // Replace with your AWS account ID
    ECR_REPO_NAME = 'my-app-repo'   // ECR repository name
    ECR_REPO_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
    IMAGE_TAG    = "${BUILD_NUMBER}"
    ECS_CLUSTER  = 'my-cluster'
    ECS_SERVICE  = 'my-service'
    CONTAINER_NAME = 'my-container'
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main',
            url: 'https://github.com/username/my-app.git'   // Replace with your repo
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          sh '''
            echo "Building Docker image with tag: ${IMAGE_TAG}"
            docker build -t ${ECR_REPO_URI}:${IMAGE_TAG} .
            docker tag ${ECR_REPO_URI}:${IMAGE_TAG} ${ECR_REPO_URI}:latest
          '''
        }
      }
    }

    stage('Push Image to ECR') {
      steps {
        script {
          sh '''
            # Login to ECR
            aws ecr get-login-password --region ${AWS_REGION} | \
              docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
            
            # Push both tags
            docker push ${ECR_REPO_URI}:${IMAGE_TAG}
            docker push ${ECR_REPO_URI}:latest
          '''
        }
      }
    }

    stage('Deploy to ECS') {
      steps {
        script {
          sh '''
            # Force new deployment with latest image
            aws ecs update-service \
              --cluster ${ECS_CLUSTER} \
              --service ${ECS_SERVICE} \
              --force-new-deployment \
              --region ${AWS_REGION}
          '''
        }
      }
    }
  }

  post {
    success {
      echo 'Pipeline completed successfully!'
    }
    failure {
      echo 'Pipeline failed. Check logs for details.'
    }
  }
}