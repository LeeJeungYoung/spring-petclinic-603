pipeline {
    agent any

    tools {
        jdk 'JDK21'
        maven 'M3'
    }
    
    environment {
        DOCKER_IMAGE_NAME = "spring-petclinic"
        DOCKERHUB_CRED = credentials('dockerCredentials')
    }
    
    stages {
        stage ('Git Clone') {
            steps {
                git url: 'https://github.com/LeeJeungYoung/spring-petclinic-603.git', 
                branch: 'main'
            }
        }
        
        stage ('Maven Build') {
            steps {
                sh 'mvn clean package -Dmaven.test.failure.ignore=true'
            }
        }
        
        stage ('Docker Image Create') {
            steps {
                echo 'Docker Image Create'
              
                sh """
                    docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} urico29/${DOCKER_IMAGE_NAME}:latest
                """
            }
        }
        
        stage ('Docker Hub Login') {
            steps {
                echo 'Docker Hub Login'
                sh 'echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin'
            }
        }
        
        stage ('Docker Image Push') {
            steps {
                echo 'Docker Image Push'
                sh """
                    docker push urico29/${DOCKER_IMAGE_NAME}:latest
                """
            }
        }

        stage ('Docker Container Run') {
            steps {
                echo 'Docker Container Run'
              
            }
        }
    } 

    post {
        always {
            echo 'Cleaning up Docker Images...'
            sh """
                docker rmi -f ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} || true
                docker rmi -f urico29/${DOCKER_IMAGE_NAME}:latest || true
            """
        }
    }
}
