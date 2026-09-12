pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    environment {
        IMAGE_NAME = "hotstar"
        DOCKER_USER = "dockerperala"
    }

    stages {

        stage('Git Checkout') {
            steps {
                git 'https://github.com/devops-perala/java-maven-hoststar.git'
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
                        -Dsonar.projectKey=hotstar \
                        -Dsonar.projectName=hotstar \
                        -Dsonar.java.binaries=target/classes
                    '''
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                nexusArtifactUploader(
                    artifacts: [[
                        artifactId: 'myapp',
                        classifier: '',
                        file: 'target/myapp.war',
                        type: 'war'
                    ]],
                    credentialsId: 'nexus',
                    groupId: 'rakesh',
                    nexusUrl: '13.232.216.188:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'rakesh',
                    version: '8.3.3'
                )
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t hotstar:latest .'
            }
        }

        stage('Docker Hub Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-cred',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | \
                        docker login -u "$DOCKER_USERNAME" --password-stdin

                        docker tag hotstar:latest \
                            ${DOCKER_USERNAME}/hotstar:latest

                        docker push ${DOCKER_USERNAME}/hotstar:latest
                    '''
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                deploy adapters: [
                    tomcat9(
                        credentialsId: 'tomcat-cred',
                        path: '',
                        url: 'http://YOUR-TOMCAT-IP:8080'
                    )
                ],
                contextPath: 'hotstar',
                war: 'target/*.war'
            }
        }
    }
}
