pipeline {
    agent any
    environment {
        IMAGE_NAME = "sample-website"
        CONTAINER_NAME = "sample-website-container"
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning the repository...'
                git 'https://github.com/shiv702/sample_website.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t ${IMAGE_NAME} .'
            }
        }
        stage('Deploy Container') {
            steps {
                echo 'Stopping existing container if any...'
                sh 'docker stop ${CONTAINER_NAME} || true && docker rm ${CONTAINER_NAME} || true'
                
                echo 'Running the new container...'
                sh 'docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}'
            }
        }
    }
    post {
        success {
            echo 'Deployment successful. Access the website using the public IP.'
        }
        failure {
            echo 'Deployment failed. Check the logs for more details.'
        }
    }
}
