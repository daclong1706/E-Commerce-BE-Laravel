pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tempure/laravel-backend:${env.BUILD_NUMBER}"
        DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-creds'
    }

    stages {
        stage('Checkout & Setup') {
            steps {
                echo 'Checking out source code...'
                git branch: 'main',
                    url: 'http://host.docker.internal:3000/admin/laravel-backend',
                    credentialsId: 'gitea-creds'
            }
        }
        
        stage('Composer Install') {
            steps {
                echo 'Installing dependencies...'
                sh "docker run --rm -v \${PWD}:/app -w /app composer install --no-interaction"
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
                echo 'Pushing Docker image...'
                withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
