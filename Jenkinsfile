pipeline {
    agent any

    tools {
        jdk 'jdk11'
        maven 'M3'
    }
    environment { 
        DOCKERHUB_CREDENTIALS = credentials('dockerCredentials')  // Docker Hub 자격 증명 ID
        REGION = "ap-northeast-2"  // AWS 리전
        AWS_CREDENTIAL_NAME = 'AWSCredentials'  // AWS 자격 증명 I
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
                // Docker Hub 로그인
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        
        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'  
                sh """
                docker push kimaudwns/bookshop:latest
                """  // Docker 이미지 푸시
            }
        }
        
        stage('Cleaning up') { 
            steps { 
                // Jenkins 서버의 사용하지 않는 Docker 이미지 제거
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
                    
                    // AWS 자격 증명과 함께 S3에 파일 업로드
                    withAWS(region: "${REGION}", credentials: "${AWS_CREDENTIAL_NAME}") {
                        s3Upload(file: "deploy.zip", bucket: "team5-codedeploy-bucket")
                    }
                    
                    sh 'rm -rf deploy.zip'  // 임시 zip 파일 삭제
                }
            }
        }

        stage('Codedeploy Workload') {
        steps {
        echo "Create Codedeploy deployment"

        withAWS(region: "${REGION}", credentials: "${AWS_CREDENTIAL_NAME}") {
            sh '''
            # Check if the deployment group exists
            deployment_group_check=$(aws deploy get-deployment-group \
                --application-name team5-codedeploy \
                --deployment-group-name team5-codedeploy-group \
                --query "deploymentGroupInfo.deploymentGroupName" \
                --output text 2>/dev/null)

            if [ "$deployment_group_check" == "None" ] || [ -z "$deployment_group_check" ]; then
                echo "Deployment group not found. Creating a new deployment group..."

                # 배포 그룹 생성
                aws deploy create-deployment-group \
                    --application-name team5-codedeploy \
                    --deployment-group-name team5-codedeploy-group \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --service-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/CodeDeployServiceRole \
                    --ec2-tag-filters Key=Name,Value=your-ec2-instance-tag,Type=KEY_AND_VALUE
            else
                echo "Deployment group already exists."
            fi

            # 새로운 배포 생성
            aws deploy create-deployment \
                --application-name team5-codedeploy \
                --deployment-config-name CodeDeployDefault.OneAtATATime \
                --deployment-group-name team5-codedeploy-group \
                --s3-location bucket=team5-codedeploy-bucket,bundleType=zip,key=deploy.zip
            '''
        }

        sleep(10)  // 10초 대기 
         }
       }   
    }
}
