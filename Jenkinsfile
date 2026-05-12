pipeline {
    agent any

    tools {
        jdk 'JDK21'
        maven 'M3'
    }
    
    environment {
        DOCKER_IMAGE_NAME = "spring-petclinic"
        DOCKER_API_VERSION = '1.43'
        COMPOSE_API_VERSION = '1.43'
        REGION = 'ap-northeast-2'  // REGIN -> REGION 오타 수정
        
        // Credentials 설정
        DOCKERHUB_CRED = credentials('dockerCredentials')
        AWS_CREDENTIAL_NAME = 'awsCredentials' // ID값인 awsCredentials를 적어주는게 맞습니다
        S3_BUCKET = '사용자님의-버킷-이름' // 이 변수가 빠져있어서 추가했습니다
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
        
        stage ('Docker Build && Push') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} urico29/${DOCKER_IMAGE_NAME}:latest
                    echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin
                    docker push urico29/${DOCKER_IMAGE_NAME}:latest
                """
            }
        }

        stage('Upload S3') {
            steps {
                echo "Upload to S3"
                dir("${env.WORKSPACE}") {
                    sh 'zip -r scripts.zip ./scripts appspec.yml'
                    withAWS(region:"${REGION}", credentials: "${AWS_CREDENTIAL_NAME}"){
                        s3Upload(file:"scripts.zip", bucket:"${S3_BUCKET}")
                    }
                }
            }
        } // <--- stage를 닫는 괄호 추가
    } // <--- stages 전체를 닫는 괄호 추가
    
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
