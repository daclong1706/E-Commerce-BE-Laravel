pipeline {
    agent any
    
    environment {
        // Tên image Docker của bạn trên Docker Hub
        DOCKER_IMAGE = "tempure/laravel-backend:${env.BUILD_NUMBER}"
        // ID của credential Docker Hub
        DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-creds'
    }

    stages {
        stage('Install Docker') {
            steps {
                echo 'Installing Docker inside the Jenkins container...'
                sh '''
                    apt-get update && apt-get install -y docker.io
                '''
            }
        }
        
        stage('Checkout & Setup') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build & Install Dependencies') {
            steps {
                echo 'Building and installing dependencies inside a Docker container...'
                script {
                    sh "docker run --rm -v \${PWD}:/app -w /app composer install --no-interaction"
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
                        sh "docker push ${DOCKER_IMAGE}"
                    }
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
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
