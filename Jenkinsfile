pipeline {
    agent any
    
    environment {
        SONAR_SCANNER_HOME = tool 'SonarQubeScanner'
        DOCKER_REGISTRY = 'your-registry.com'
        DOCKER_IMAGE_NAME = 'ecommerce-laravel-backend'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout & Setup') {
            steps {
                echo 'Checking out source code...'
                checkout scm
                
                echo 'Installing all PHP dependencies...'
                sh 'composer install --no-interaction'

                sh 'cp .env.example .env'
                sh 'php artisan key:generate'
            }
        }
        
        stage('Test & Coverage') {
            steps {
                echo 'Running tests with coverage...'
                sh 'php artisan test --coverage-clover=coverage.xml --log-junit=junit.xml'
                
                publishTestResults testResultsPattern: 'junit.xml'
            }
        }
        
        stage('Code Quality Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar-token')
            }
            steps {
                echo 'Running SonarQube analysis...'
                withSonarQubeEnv('SonarQube') {
                    sh "${SONAR_SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectVersion=${BUILD_NUMBER} -Dsonar.login=${SONAR_TOKEN}"
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                echo 'Checking SonarQube Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    def dockerImage = docker.build("${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}")
                    
                    // Also tag as latest
                    sh "docker tag ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest"
                    
                    // Store image info for next stage
                    env.DOCKER_IMAGE_FULL = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Push Docker Image') {
            environment {
                DOCKER_CREDENTIALS = credentials('docker-registry-credentials')
            }
            steps {
                echo 'Pushing Docker image to registry...'
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry-credentials') {
                        // Push with build number tag
                        sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                        
                        // Push latest tag
                        sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest"
                    }
                }
                
                echo "Docker image pushed: ${env.DOCKER_IMAGE_FULL}"
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace and Docker images...'
            
            // Clean up local Docker images to save space
            sh """
                docker rmi ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG} || true
                docker rmi ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest || true
                docker system prune -f || true
            """
            
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
