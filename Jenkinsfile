pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        IMAGE_NAME = "hotstar"
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
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                    mvn sonar:sonar \
                    -Dsonar.projectKey=hotstar
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t hotstar:latest .'
            }
        }

        stage('Docker Hub Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-cred',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                    echo $PASS | docker login -u $USER --password-stdin

                    docker tag hotstar:latest dockerperala/hotstar:latest

                    docker push dockerperala/hotstar:latest
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                docker rm -f hotstar || true

                docker run -d \
                --name hotstar \
                -p 8080:8080 \
                dockerperala/hotstar:latest
                '''
            }
        }
    }

    post {
        success {
            echo 'Hotstar application deployed successfully'
            echo 'Open: http://SERVER-IP:8080/hotstar/'
        }

        failure {
            echo 'Pipeline failed. Check Jenkins console output.'
        }
    }
}
