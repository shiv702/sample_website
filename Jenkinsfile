pipeline {
    agent any
    environment {
        IMAGE_NAME = 'sample-website'          // Docker image name
        DOCKER_WORK_DIR = '/tmp/deploy'        // Working directory on EC2
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
                                # SSH into EC2 instance and prepare Docker environment
                                ssh -o StrictHostKeyChecking=no ubuntu@${server} '
                                    sudo mkdir -p ${env.DOCKER_WORK_DIR} &&
                                    sudo rm -rf ${env.DOCKER_WORK_DIR}/* &&
                                    sudo docker stop ${env.IMAGE_NAME} || true &&
                                    sudo docker rm ${env.IMAGE_NAME} || true
                                '
                                
                                # Copy necessary files to EC2 instance
                                scp -o StrictHostKeyChecking=no Dockerfile index.html ubuntu@${server}:${env.DOCKER_WORK_DIR}/
                                
                                # Build and run Docker container on EC2 instance
                                ssh -o StrictHostKeyChecking=no ubuntu@${server} '
                                    cd ${env.DOCKER_WORK_DIR} &&
                                    sudo docker build -t ${env.IMAGE_NAME} . &&
                                    sudo docker run -d -p 80:80 --name ${env.IMAGE_NAME} ${env.IMAGE_NAME}
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
