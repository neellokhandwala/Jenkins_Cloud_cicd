pipeline {
    agent { label 'local' }

    tools {
        jdk 'jdk17'
    }

    environment {
        AWS_REGION     = 'ap-south-1'
        AWS_ACCOUNT_ID = '965638719568'

        ECR_REPO = 'dockerimagestore'
        ECR_URI  = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"

        IMAGE_TAG = "${env.GIT_COMMIT ?: env.BUILD_NUMBER}"
        S3_BUCKET = 'practice-artifact-jenkins'

        ECS_CLUSTER = 'demoecscluster'
        ECS_SERVICE = 'demoecstask-service-tlicncom'
    }

    stages {

        /* CHECKOUT */
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-token',
                    url: 'https://github.com/neellokhandwala/Jenkins_Cloud_cicd.git'
            }
        }

        /* BUILD & UNIT TEST */
        stage('Build & Unit Test') {
            steps {
                bat 'mvn clean package -DskipTests'
            }
        }

        /* BACKUP ARTIFACT TO S3 */
        stage('Backup Artifact to S3') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    bat '''
                    for %%f in (target\\*.jar) do (
                        aws s3 cp "%%f" s3://%S3_BUCKET%/builds/%BUILD_NUMBER%.jar
                    )
                    '''
                }
            }
        }

        /* DOCKER BUILD */
        stage('Docker Build') {
            steps {
                bat '''
                docker build -t %ECR_REPO%:%IMAGE_TAG% .
                '''
            }
        }

        /* TAG & PUSH TO ECR (WITH latest) */
        stage('Push Image to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    bat '''
                    aws ecr get-login-password --region %AWS_REGION% ^
                    | docker login --username AWS --password-stdin %ECR_URI%

                    docker tag %ECR_REPO%:%IMAGE_TAG% %ECR_URI%:%IMAGE_TAG%
                    docker tag %ECR_REPO%:%IMAGE_TAG% %ECR_URI%:latest

                    docker push %ECR_URI%:%IMAGE_TAG%
                    docker push %ECR_URI%:latest
                    '''
                }
            }
        }

        /* MANUAL APPROVAL */
        stage('Approval') {
            steps {
                input message: 'Deploy to ECS production?'
            }
        }

        /* ECS DEPLOY */
        stage('ECS Deploy') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    bat '''
                    aws ecs update-service ^
                      --cluster %ECS_CLUSTER% ^
                      --service %ECS_SERVICE% ^
                      --force-new-deployment
                    '''
                }
            }
        }

        /* WAIT FOR STABILITY */
        stage('Wait for ECS') {
            steps {
                bat 'ping 127.0.0.1 -n 60 > nul'
            }
        }
    }

    post {
        success {
            echo "Deployment triggered successfully."
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
