pipeline {
    agent any
    environment {
        IMAGE_NAME = 'sample-website'          // Docker image name
        CONTAINER_NAME = 'sample-website-container' // Docker container name
        DOCKER_WORK_DIR = '/usr/share/nginx/html'        // Working directory on EC2
        SERVERS = '13.49.46.222'               // Comma-separated list of server IPs
        SSH_CREDENTIALS = 'SSH_CREDENTIALS' // Replace with your Jenkins SSH credentials ID
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
        stage('Push Docker Image (Optional)') {
            steps {
                echo 'Tagging and pushing Docker image to repository...'
                withCredentials([usernamePassword(credentialsId: 'Docker-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh """
                        echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                        docker tag ${env.IMAGE_NAME} \$DOCKER_USERNAME/${env.IMAGE_NAME}:latest
                        docker push \$DOCKER_USERNAME/${env.IMAGE_NAME}:latest
                    """
                }
            }
        }
        stage('Deploy to EC2 Instances') {
            steps {
                script {
                    def servers = env.SERVERS.split(',')
                    servers.each { server ->
                        echo "Deploying to ${server}..."
                        sshagent([env.SSH_CREDENTIALS]) {
                            sh """
                                # Ensure directory exists and set permissions for the ubuntu user
                                ssh -o StrictHostKeyChecking=no ubuntu@${server} '
                                    sudo mkdir -p ${env.DOCKER_WORK_DIR} &&
                                    sudo chown ubuntu:ubuntu ${env.DOCKER_WORK_DIR}
                                '
                                
                                # Stop and remove the container gracefully
                                ssh -o StrictHostKeyChecking=no ubuntu@${server} '
                                    docker stop ${env.CONTAINER_NAME} 2>/dev/null || true &&
                                    docker rm ${env.CONTAINER_NAME} 2>/dev/null || true
                                '

                                  # Free port 80 if it is already in use
                                ssh -o StrictHostKeyChecking=no ubuntu@${server} '
                                    PID=$(sudo lsof -t -i:80) &&
                                    if [ ! -z "$PID" ]; then sudo kill -9 $PID; fi
                                '

                                # Copy files to the EC2 instance
                                scp -o StrictHostKeyChecking=no Dockerfile index.html ubuntu@${server}:${env.DOCKER_WORK_DIR}/

                                # Build and run the Docker container
                                ssh -o StrictHostKeyChecking=no ubuntu@${server} '
                                    cd ${env.DOCKER_WORK_DIR} &&
                                    docker build -t ${env.IMAGE_NAME} . &&
                                    docker run -d -p 80:80 --name ${env.CONTAINER_NAME} ${env.IMAGE_NAME}
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
