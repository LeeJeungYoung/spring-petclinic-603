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
        REGION = 'ap-northeast-2'
        
        
        DOCKERHUB_CRED = credentials('dockerCredentials')
        AWS_CREDENTIAL_NAME = 'awsCredentials'
    }
    
    stages {
        stage ('Git Clone') {
            steps {
                git url: 'https://github.com/LeeJeungYoung/spring-petclinic-603.git', 
                branch: 'main', credentialsId: 'gitCredentials'
            }
        }
        
        stage ('Maven Build') {
            steps {
                echo 'Maven Build'
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
                sh 'rm -rf ./scripts.zip'
                }
            }
        }
        stage('Codedeploy workload') {
            steps {
                echo "create code-deploy group"
                withAWS(region:"${REGION}", credentials: "${AWS_CREDENTIAL_NAME}") {      
                    sh """
                    aws deploy create-deployment-group \
                    --application-name ${CODE_DEPLOY_NAME} \
                    --auto-scaling-groups aws03-target-asg \
                    --deployment-group-name ${CODE_DEPLOY_NAME}-${BUILD_NUMBER} \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --service-role-arn ${CODE_DEPLOY_SERVICE_ROLE} \
                    """
                    echo "codedeploy workload"
                    sh """
                    aws deploy create-deployment --application-name ${CODE_DEPLOY_NAME} \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --deployment-group-name ${CODE_DEPLOY_NAME}-${BUILD_NUMBER} \
                    --s3-location bucket=${S3_BUCKET}, bundleType=zip, key=scripts.zip
                    """
                    sleep(10)
                }
            }    
        }    
    }
}
