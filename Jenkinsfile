pipeline {
    agent {
        docker {
            image 'php:8.2-cli'    // Base image for build
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        REPO_URL = 'http://host.docker.internal:3000/admin/laravel-backend.git'
        BRANCH   = 'main'
        CREDS_ID = 'gitea-creds-id'   // Replace with Jenkins credential ID for Gitea
    }

    stages {
        stage('Checkout') {
            steps {
                git(
                    url: env.REPO_URL,
                    branch: env.BRANCH,
                    credentialsId: env.CREDS_ID
                )
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    php -v
                    composer install --no-interaction --prefer-dist --optimize-autoloader
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    vendor/bin/phpunit --testdox
                '''
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh '''
                    docker build -t laravel-backend:latest .
                    docker tag laravel-backend:latest my-docker-registry/laravel-backend:latest
                    docker push my-docker-registry/laravel-backend:latest
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'docker system prune -f'
        }
        success {
            echo '✅ Build & Tests passed successfully!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
