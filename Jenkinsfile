node {
    // vars
    def DOCKER_IMAGE = "tempure/laravel-backend:${env.BUILD_NUMBER}"
    def DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-creds'
    def GITEA_CREDENTIALS_ID = 'gitea-creds'
    // Jenkins stores workspaces in the named volume "jenkins_home"
    def VOLUME_NAME = 'jenkins_home'
    def WS_IN_VOL   = "/jenkins_home/workspace/${env.JOB_NAME}"  // same files as ${WORKSPACE}, but visible to host Docker

    try {
        stage('Checkout & Setup') {
            echo 'Checking out source code...'
            checkout([
                $class: 'GitSCM',
                branches: [[name: '*/main']],
                userRemoteConfigs: [[
                    url: 'http://host.docker.internal:3000/admin/laravel-backend',
                    credentialsId: GITEA_CREDENTIALS_ID
                ]]
            ])

            echo 'Listing workspace contents:'
            sh 'ls -la'

            // sanity: composer.json must exist
            if (!fileExists('composer.json')) {
                error 'composer.json NOT found at repo root.'
            }
        }

        stage('Composer Install') {
            echo 'Installing dependencies...'
            sh """
              docker run --rm \
                -v ${VOLUME_NAME}:/jenkins_home \
                -w ${WS_IN_VOL} \
                composer:2 install --no-interaction --prefer-dist --no-dev --optimize-autoloader
            """
        }

        stage('Build Docker Image') {
            echo 'Building Docker image...'
            sh """
              docker build -t ${DOCKER_IMAGE} ${WS_IN_VOL}
            """
        }

        stage('Push Docker Image') {
            echo 'Pushing image to Docker Hub...'
            withCredentials([usernamePassword(
                credentialsId: DOCKER_HUB_CREDENTIALS_ID,
                usernameVariable: 'DOCKER_USERNAME',
                passwordVariable: 'DOCKER_PASSWORD'
            )]) {
                sh """
                  echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin
                  docker push ${DOCKER_IMAGE}
                """
            }
        }
    } finally {
        stage('Cleanup') {
            echo 'Cleaning up workspace...'
            deleteDir()
        }
    }
}
