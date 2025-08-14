pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "my-laravel-app"
        DOCKER_TAG = "latest"
        REGISTRY = "my-docker-registry.com"
    }

    stages {
        stage('Checkout') {
            steps {
                git(
                    url: 'http://host.docker.internal:3000/admin/laravel-backend.git',
                    branch: 'main',
                    credentialsId: 'gitea-creds-id'
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh """
                  docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image..."
                sh """
                  docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                  docker push ${REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                """
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying application..."
                // Example deployment command
                sh """
                  docker run -d --name ${DOCKER_IMAGE} -p 8000:8000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                """
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace..."
            cleanWs()
        }
        failure {
            echo "Pipeline failed!"
        }
        success {
            echo "Pipeline succeeded!"
        }
    }
}
