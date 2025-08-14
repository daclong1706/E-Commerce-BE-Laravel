pipeline {
    agent any

    environment {
        // Docker image name with build number tag
        DOCKER_IMAGE = "tempure/laravel-backend:${env.BUILD_NUMBER}"
        // Docker Hub credential ID from Jenkins
        DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-creds'
        // Gitea credential ID from Jenkins
        GITEA_CREDENTIALS_ID = 'gitea-creds'
    }

    stages {
        stage('Checkout & Setup') {
            steps {
                echo 'Checking out source code from Gitea...'
                git branch: 'main',
                    url: 'http://host.docker.internal:3000/admin/laravel-backend',
                    credentialsId: "${GITEA_CREDENTIALS_ID}"
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing PHP dependencies using Composer inside container...'
                sh '''
                    docker run --rm \
                        -v "$PWD":/app \
                        -w /app \
                        composer:latest \
                        install --no-interaction --prefer-dist --no-dev
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Logging in to Docker Hub and pushing image...'
                withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh """
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
