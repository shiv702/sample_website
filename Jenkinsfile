pipeline {
    agent any
    environment {
        // Define the necessary environment variables
        IMAGE_NAME = 'sample-website'  // Change to your image name if needed
        DOCKER_WORK_DIR = '/tmp/deploy'  // Change the work directory as needed
        SERVERS = env.SERVERS.split(',') // Split SERVERS variable into a list
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning the repository...'
                // Specify the branch and repository explicitly
                git branch: 'main', url: 'https://github.com/shiv702/sample_website.git', credentialsId: 'github-credentials-id' // Replace with your credentialsId
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                // Build the Docker image
                sh "docker build -t ${env.IMAGE_NAME} ."
            }
        }
        stage('Push Docker Image (Optional)') {
            steps {
                echo 'Tagging and pushing Docker image to repository...'
                // Tag and push to Docker Hub (Optional)
                sh "docker tag ${env.IMAGE_NAME} <dockerhub-username>/${env.IMAGE_NAME}:latest"
                sh "docker push <dockerhub-username>/${env.IMAGE_NAME}:latest"
            }
        }
        stage('Deploy to EC2 Instances') {
            steps {
                script {
                    // Iterate through all servers for deployment
                    for (server in SERVERS) {
                        echo "Deploying to ${server}..."
                        sshagent([env.SSH_CREDENTIALS]) {
                            // SSH commands for deployment
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
