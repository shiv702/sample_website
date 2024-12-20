pipeline {
    agent any
    environment {
        IMAGE_NAME = 'sample-website'               // Docker image name
        CONTAINER_NAME = 'sample-website-container' // Docker container name
        DOCKER_WORK_DIR = '/usr/share/nginx/html'   // Working directory on EC2
        SERVERS = '13.49.46.222,13.53.176.48'       // Comma-separated list of server IPs
        SSH_CREDENTIALS = 'SSH_CREDENTIALS'         // Replace with your Jenkins SSH credentials ID
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning the repository...'
                git branch: 'main', url: 'https://github.com/shiv702/sample_website.git', credentialsId: 'github-credentials-id' // Replace with your credentials ID
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${env.IMAGE_NAME} ."
            }
        }
        stage('Deploy to EC2 Instances') {
            parallel {
                stage('Deploy to 13.49.46.222') {
                    steps {
                        sshagent([env.SSH_CREDENTIALS]) {
                            sh """
                                # Ensure directory exists and set permissions for the ubuntu user
                                ssh -o StrictHostKeyChecking=no ubuntu@13.49.46.222 '
                                    sudo mkdir -p ${env.DOCKER_WORK_DIR} &&
                                    sudo chown ubuntu:ubuntu ${env.DOCKER_WORK_DIR}
                                '

                                # Stop and remove the container gracefully
                                ssh -o StrictHostKeyChecking=no ubuntu@13.49.46.222 '
                                    docker stop ${env.CONTAINER_NAME} 2>/dev/null || true &&
                                    docker rm ${env.CONTAINER_NAME} 2>/dev/null || true
                                '

                                # Copy files to the EC2 instance
                                scp -o StrictHostKeyChecking=no Dockerfile index.html ubuntu@13.49.46.222:${env.DOCKER_WORK_DIR}/

                                # Build and run the Docker container
                                ssh -o StrictHostKeyChecking=no ubuntu@13.49.46.222 '
                                    cd ${env.DOCKER_WORK_DIR} &&
                                    docker build -t ${env.IMAGE_NAME} . &&
                                    docker run -d -p 81:80 --name ${env.CONTAINER_NAME} ${env.IMAGE_NAME}
                                '
                            """
                        }
                    }
                }
                stage('Deploy to 13.53.176.48') {
                    steps {
                        sshagent([env.SSH_CREDENTIALS]) {
                            sh """
                                # Ensure directory exists and set permissions for the ubuntu user
                                ssh -o StrictHostKeyChecking=no ubuntu@13.53.176.48 '
                                    sudo mkdir -p ${env.DOCKER_WORK_DIR} &&
                                    sudo chown ubuntu:ubuntu ${env.DOCKER_WORK_DIR}
                                '

                                # Stop and remove the container gracefully
                                ssh -o StrictHostKeyChecking=no ubuntu@13.53.176.48 '
                                    docker stop ${env.CONTAINER_NAME} 2>/dev/null || true &&
                                    docker rm ${env.CONTAINER_NAME} 2>/dev/null || true
                                '

                                # Copy files to the EC2 instance
                                scp -o StrictHostKeyChecking=no Dockerfile index.html ubuntu@13.53.176.48:${env.DOCKER_WORK_DIR}/

                                # Build and run the Docker container
                                ssh -o StrictHostKeyChecking=no ubuntu@13.53.176.48 '
                                    cd ${env.DOCKER_WORK_DIR} &&
                                    docker build -t ${env.IMAGE_NAME} . &&
                                    docker run -d -p 81:80 --name ${env.CONTAINER_NAME} ${env.IMAGE_NAME}
                                '
                            """
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Deployment successful on all servers!'
        }
        failure {
            echo 'Deployment failed. Check logs for details.'
        }
    }
}
