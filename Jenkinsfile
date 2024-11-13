pipeline {
    agent any

    tools {
        jdk 'jdk11'
        maven 'M3'
    }
    environment { 
        DOCKERHUB_CREDENTIALS = credentials('dockerCredentials') 
        REGION = "ap-northeast-2"  
        AWS_CREDENTIAL_NAME = 'AWSCredentials' 
    }

    stages {
        stage('Git Clone') {
            steps {
                echo 'Git Clone'
                git url: 'https://github.com/kimaudwns/BookShop.git',
                branch: 'main', credentialsId: 'gitToken'
            }
            post {
                success {
                    echo 'Success git clone step'
                }
                failure {
                    echo 'Fail git clone step'
                }
            }
        }

        stage('Maven Build') {
            steps {
                echo 'Maven Build'
                dir('bookShop01'){
                    sh 'mvn -Dmaven.test.failure.ignore=true package'
                }
            }
        }

        stage('Docker Image Build') {
            steps {
                echo 'Docker Image build'                
                dir("${env.WORKSPACE}") {
                    sh """
                    docker build -t kimaudwns/bookshop:${BUILD_NUMBER} .
                    docker tag kimaudwns/bookshop:${BUILD_NUMBER} kimaudwns/bookshop:latest
                    """
                }
            }
        }

        stage('Docker Login') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'  
                sh """
                docker push kimaudwns/bookshop:${BUILD_NUMBER}
                docker push kimaudwns/bookshop:latest
                """  
            }
        }

        stage('Cleaning up') { 
            steps { 
                echo 'Cleaning up unused Docker images on Jenkins server'
                sh """
                docker rmi kimaudwns/bookshop:${BUILD_NUMBER}
                """
            }
        }

        stage('Upload S3') {
            steps {
                echo "Upload to S3"
                dir("${env.WORKSPACE}") {
                    sh 'zip -r deploy.zip ./deploy appspec.yml'
                    
                    withAWS(region: "${REGION}", credentials: "${AWS_CREDENTIAL_NAME}") {
                        s3Upload(file: "deploy.zip", bucket: "team5-codedeploy-bucket")
                    }
                    
                    sh 'rm -rf deploy.zip'
                }
            }
        }

        stage('Codedeploy Workload') {
            steps {
                echo "create Codedeploy deployment"

                withAWS(region: "${REGION}", credentials: "${AWS_CREDENTIAL_NAME}") {
                    // 배포 그룹 존재 여부 확인 후 생성
                    sh '''
                    aws deploy delete-deployment-group --application-name team5-codedeploy --deployment-group-name team5-codedeploy-group || echo "Deployment group does not exist"
                    aws deploy create-deployment-group \
                    --application-name team5-codedeploy \
                    --auto-scaling-groups team5-asg \
                    --deployment-group-name team5-codedeploy-group \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --service-role-arn arn:aws:iam::491085389788:role/team5-CodeDeployServiceRole
                    '''

                    // 배포 생성
                    DEPLOYMENT_ID=$(aws deploy create-deployment \
                    --application-name team5-codedeploy \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --deployment-group-name team5-codedeploy-group \
                    --s3-location bucket=team5-codedeploy-bucket,bundleType=zip,key=deploy.zip | jq -r '.deploymentId')

                    // 배포 상태 확인
                    aws deploy get-deployment --deployment-id $DEPLOYMENT_ID
                }
            }
        }
    }
}
