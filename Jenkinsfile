node {
    // Define environment variables
    def DOCKER_IMAGE = "tempure/laravel-backend:${env.BUILD_NUMBER}"
    def DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-creds'

    try {
        stage('Checkout & Setup') {
            echo 'Checking out source code...'
            checkout([
                $class: 'GitSCM',
                branches: [[name: '*/main']],
                userRemoteConfigs: [[
                    url: 'http://host.docker.internal:3000/admin/laravel-backend',
                    credentialsId: 'gitea-creds'
                ]]
            ])
            
            // Verify workspace contents
            echo 'Listing workspace contents:'
            sh 'ls -la'
            
            // Check if composer.json exists
            script {
                if (!fileExists('composer.json')) {
                    error 'composer.json file not found in the repository root!'
                }
            }
        }

        stage('Composer Install') {
            echo 'Installing dependencies...'
            // Fix volume mounting for Jenkins workspace
            sh "docker run --rm -v ${WORKSPACE}:/app -w /app composer:2 install --no-interaction --no-dev --optimize-autoloader"
        }

        stage('Build Docker Image') {
            echo 'Building Docker image...'
            sh "docker build -t ${DOCKER_IMAGE} ."
        }

        stage('Push Docker Image') {
            echo 'Pushing Docker image to Docker Hub...'
            withCredentials([usernamePassword(
                credentialsId: DOCKER_HUB_CREDENTIALS_ID,
                passwordVariable: 'DOCKER_PASSWORD',
                usernameVariable: 'DOCKER_USERNAME'
            )]) {
                sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                sh "docker push ${DOCKER_IMAGE}"
            }
        }
    } finally {
        stage('Cleanup') {
            echo 'Cleaning up workspace...'
            deleteDir()
        }
    }
}
