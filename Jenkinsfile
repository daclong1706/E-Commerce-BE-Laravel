node {
    // Image tags
    def DOCKER_IMAGE         = "tempure/laravel-backend:${env.BUILD_NUMBER}"
    def DOCKER_IMAGE_LATEST  = "tempure/laravel-backend:latest"

    // Credentials
    def DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-creds'
    def GITEA_CREDENTIALS_ID      = 'gitea-creds' // remove if your repo is public

    // IMPORTANT: use the named volume so the host Docker daemon can see the workspace
    def VOLUME_NAME = 'jenkins_home'
    def WS_IN_VOL   = "/jenkins_home/workspace/${env.JOB_NAME}"

    try {
        stage('Checkout') {
            checkout([
                $class: 'GitSCM',
                branches: [[name: '*/main']],
                userRemoteConfigs: [[
                    url: 'http://host.docker.internal:3000/admin/laravel-backend',
                    credentialsId: GITEA_CREDENTIALS_ID   // remove this line if public
                ]]
            ])
            echo 'Workspace listing:'
            sh 'ls -la'
            if (!fileExists('Dockerfile')) {
                error 'Dockerfile not found at repo root.'
            }
            if (!fileExists('nginx.conf')) {
                error 'nginx.conf not found at repo root.'
            }
        }

        stage('Docker Sanity') {
            sh 'docker version'
        }

        stage('Build Image') {
            // Use path inside the mounted volume so host Docker can access files
            sh """
              DOCKER_BUILDKIT=1 docker build \
                -t ${DOCKER_IMAGE} \
                -t ${DOCKER_IMAGE_LATEST} \
                ${WS_IN_VOL}
            """
        }

        stage('Push Image') {
            withCredentials([usernamePassword(
                credentialsId: DOCKER_HUB_CREDENTIALS_ID,
                usernameVariable: 'DOCKER_USERNAME',
                passwordVariable: 'DOCKER_PASSWORD'
            )]) {
                sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin'
                sh "docker push ${DOCKER_IMAGE}"
                sh "docker push ${DOCKER_IMAGE_LATEST}"
            }
        }
    } finally {
        stage('Cleanup') {
            deleteDir()
        }
    }
}
