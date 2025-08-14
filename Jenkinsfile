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
        }

        stage('Composer Install') {
            echo 'Installing dependencies...'
            sh "docker run --rm -v ${pwd()}:/app -w /app composer install --no-interaction"
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
