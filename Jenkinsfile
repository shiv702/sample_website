pipeline {
    agent any
    environment {
        IMAGE_NAME = 'sample-website'  // Docker image name
        DOCKER_WORK_DIR = '/tmp/deploy'  // Working directory on EC2
        SERVERS = env.SERVERS.split(',') // Split SERVERS into a list
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
                // Login to Docker Hub using credentials stored in Jenkins
                withCredentials([usernamePassword(credentialsId: 'Docker-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh """
                        # Log in to Docker Hub using credentials from Jenkins credentials store
                        docker login -u \$DOCKER_USERNAME -p \$DOCKER_PASSWORD
                        docker tag ${env.IMAGE_NAME} \$DOCKER_USERNAME/${env.IMAGE_NAME}:latest
                        docker push \$DOCKER_USERNAME/${env.IMAGE_NAME}:latest
                    """
                }
            }
        }
        stage('Deploy to EC2 Instances') {
            steps {
                script {
                    // Iterate through all servers for deployment
                    for (server in SERVERS) {
                        echo "Deploying to ${server}..."
                        sshagent([env.SSH_CREDENTIALS]) {
                            sh """
                                ssh -o StrictHostKeyChecking=no ec2-user@${server} "
                                    sudo mkdir -p ${env.DOCKER_WORK_DIR} &&
                                    sudo rm -rf ${env.DOCKER_WORK_DIR}/* &&
                                    sudo docker stop ${env.IMAGE_NAME} || true &&
                                    sudo docker rm ${env.IMAGE_NAME} || true
                                "
                                scp -o StrictHostKeyChecking=no Dockerfile index.html ec2-user@${server}:${env.DOCKER_WORK_DIR}/
                                ssh -o StrictHostKeyChecking=no ec2-user@${server} "
                                    cd ${env.DOCKER_WORK_DIR} &&
                                    sudo docker build -t ${env.IMAGE_NAME} . &&
                                    sudo docker run -d -p 80:80 --name ${env.IMAGE_NAME} ${env.IMAGE_NAME}
                                "
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
