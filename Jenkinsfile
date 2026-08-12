pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        IMAGE_NAME  = "hotstar"
        DOCKER_USER = "dockerperala"
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/devops-perala/java-maven-hoststar.git'
            }
        }

        stage('Build') {
            steps {
                sh '''
                    echo "===== MAVEN BUILD STARTED ====="
                    mvn clean package
                    echo "===== MAVEN BUILD COMPLETED ====="
                '''
            }
        }

        stage('SonarQube Scan') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'

                    withSonarQubeEnv('SonarQube') {
                        sh """
                            echo "===== SONARQUBE SCAN STARTED ====="

                            ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=hotstar \
                                -Dsonar.projectName=hotstar \
                                -Dsonar.sources=src/main \
                                -Dsonar.tests=src/test \
                                -Dsonar.java.binaries=target/classes

                            echo "===== SONARQUBE SCAN COMPLETED ====="
                        """
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "===== DOCKER BUILD STARTED ====="

                    docker build \
                        -t ${IMAGE_NAME}:latest .

                    echo "===== DOCKER IMAGE CREATED ====="

                    docker images | grep ${IMAGE_NAME}
                '''
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-cred',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "===== DOCKER HUB LOGIN ====="

                        echo "$DOCKER_PASSWORD" | \
                        docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin
                    '''
                }
            }
        }

        stage('Docker Tag') {
            steps {
                sh '''
                    echo "===== TAGGING IMAGE ====="

                    docker tag \
                        ${IMAGE_NAME}:latest \
                        ${DOCKER_USER}/${IMAGE_NAME}:latest

                    docker images | grep ${IMAGE_NAME}
                '''
            }
        }

        stage('Docker Hub Push') {
            steps {
                sh '''
                    echo "===== PUSHING IMAGE TO DOCKER HUB ====="

                    docker push \
                        ${DOCKER_USER}/${IMAGE_NAME}:latest

                    echo "===== IMAGE PUSH COMPLETED ====="
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    echo "===== DEPLOYMENT STARTED ====="

                    docker rm -f ${IMAGE_NAME} || true

                    docker pull \
                        ${DOCKER_USER}/${IMAGE_NAME}:latest

                    docker run -d \
                        --name ${IMAGE_NAME} \
                        --restart unless-stopped \
                        -p 8080:8080 \
                        ${DOCKER_USER}/${IMAGE_NAME}:latest

                    echo "===== CONTAINER STATUS ====="

                    docker ps

                    echo "===== DEPLOYMENT COMPLETED ====="
                '''
            }
        }

        stage('Application Validation') {
            steps {
                sh '''
                    echo "===== APPLICATION VALIDATION ====="

                    sleep 10

                    docker ps | grep ${IMAGE_NAME}

                    echo "Application container is running."
                    echo "Access application on port 8080."
                '''
            }
        }
    }

    post {

        success {
            echo '''
========================================
PIPELINE SUCCESS
========================================
Git Checkout      : SUCCESS
Maven Build       : SUCCESS
SonarQube Scan    : SUCCESS
Docker Build      : SUCCESS
Docker Hub Push   : SUCCESS
Deployment        : SUCCESS

Hotstar application deployed successfully.

Open:
http://SERVER-IP:8080/hotstar/
========================================
'''
        }

        failure {
            echo '''
========================================
PIPELINE FAILED
========================================
Check the failed Jenkins stage
and Jenkins Console Output.
========================================
'''
        }

        always {
            sh '''
                echo "===== FINAL CONTAINER STATUS ====="
                docker ps -a || true
            '''
        }
    }
}
