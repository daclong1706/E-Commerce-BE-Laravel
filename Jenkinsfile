properties([
  parameters([
    booleanParam(name: 'RUN_CHECKOUT', defaultValue: false, description: 'Run Checkout stage to refresh workspace'),
    string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'Git branch to build'),
    booleanParam(name: 'DOCKER_SANITY', defaultValue: false, description: 'Run Docker Sanity stage')
  ])
])

node {
    // Image tags
    def DOCKER_IMAGE         = "tempure/laravel-backend:${env.BUILD_NUMBER}"
    def DOCKER_IMAGE_LATEST  = "tempure/laravel-backend:latest"
    // Add MongoDB ext version for Docker build
    def MONGODB_EXT_VER      = '1.21.1'

    // Credentials
    def DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-creds'
    def GITEA_CREDENTIALS_ID      = 'gitea-creds' // remove if your repo is public

    // IMPORTANT: use the named volume so the host Docker daemon can see the workspace
    def VOLUME_NAME = 'jenkins_home'
    def WS_IN_VOL   = "/jenkins_home/workspace/${env.JOB_NAME}"

    try {
        stage('Checkout') {
            if (params.RUN_CHECKOUT) {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${params.GIT_BRANCH}"]],
                    userRemoteConfigs: [[
                        url: 'http://host.docker.internal:3000/admin/laravel-backend',
                        credentialsId: GITEA_CREDENTIALS_ID   // remove this line if public
                    ]]
                ])
                echo 'Workspace listing:'
                sh 'ls -la'
                if (!fileExists('Dockerfile')) { error 'Dockerfile not found at repo root.' }
                if (!fileExists('nginx.conf')) { error 'nginx.conf not found at repo root.' }
            } else {
                echo 'Checkout skipped (RUN_CHECKOUT=false)'
            }
        }

        stage('Docker Sanity') {
            if (params.DOCKER_SANITY) {
                sh 'docker version'
            } else {
                echo 'Docker sanity skipped (DOCKER_SANITY=false)'
            }
        }

        stage('Build Image') {
            retry(2) {
                sh """
                    set -euo pipefail
                    # Preflight: ensure required files exist when Checkout is disabled
                    [ -f Dockerfile ] && [ -f nginx.conf ] || {
                      echo 'Required files missing in workspace. Re-enable Checkout stage or populate workspace.' >&2
                      exit 1
                    }
                    DOCKER_BUILDKIT=1 \
                    tar -C "${WORKSPACE}" -cf - . \
                    | docker build --pull --progress=plain \
                        --build-arg MONGODB_EXT_VER=${MONGODB_EXT_VER} \
                        -t ${DOCKER_IMAGE} -t ${DOCKER_IMAGE_LATEST} -
                """
            }
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
                sh 'docker logout || true'
            }
        }
    } finally {
        stage('Cleanup') {
            deleteDir()
        }
    }
}
