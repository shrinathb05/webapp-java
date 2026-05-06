@Library('shared') _
pipeline {
    agent {
        label 'agent1'
    }
    
    environment {
        GIT_REPO = 'https://github.com/shrinathb05/devops-portfolio.git'
        GIT_BRANCH = 'release'
        SONAR_SERVER_NAME = "sonar-server"

        WAR_NAME = "target/*.war"
        SCAN_REPORT = "target/dependency-check-report.xml"
        WORK_DIR = "/home/ubuntu/var/work/javawebapp"
        SNYK_TOKEN_SECRET_ID = "dev/snyk/token/snyk-api-token"
        
        // WORK_DIR = '/home/ubuntu/var/work/portfolio'
        TEST_REPORTS_DIR = 'test-reports'
        TEST_REPORT_FILE = 'test-reports/vitest-junit.xml'
        SNYK_ORG_ID = 'f687dcdd-f893-40db-847d-bcce9c064a10'
        
        // AWS details
        AWS_ACCOUNT_ID = "356315793521"
        ECR_REPO_NAME  = "javawebapp"
        AWS_ECR_REPO = "356315793521.dkr.ecr.us-east-1.amazonaws.com"
        AWS_REGION = "us-east-1"
        FULL_IMAGE = "${AWS_ECR_REPO}/${ECR_REPO_NAME}:${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('clean & Checkout') {
            steps {
                sh "mkdir -p ${WORK_DIR}"
                dir("${WORK_DIR}") {
                    sh "rm -rf ./*"
                    clone("https://github.com/shrinathb05/webapp-java.git","main")
                    sh "ls -lrt"
                }
            }
        }
        
        stage('Build & Test') {
            steps {
                dir("${WORK_DIR}") {
                    echo "Compiling and running the unit tests......."
                    sh "mvn clean verify"
                }
            }
            post {
                always {
                    dir("${WORK_DIR}") {
                        junit '**/target/surefire-reports/*.xml'
                    }
                }
            }
        }
        
        stage('Sonarqube Analysis') {
            steps {
                dir("${WORK_DIR}") {
                    withSonarQubeEnv("${env.SONAR_SERVER_NAME}") {
                        echo "Performing sonarqube analysis for the code......"
                        sh "mvn sonar:sonar"
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                script {
                    echo "Waiting for the quality gate......"
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted: SonarQube Quality Gate failed (${qg.status})"
                        }
                    }
                }
            }
        }
        
        stage('Snyk Security Scan') {
            steps {
                dir("${WORK_DIR}") {
                      script {
                        // If using the CLI to fetch manually (Option 1)
                        def snykToken = sh(script: "aws secretsmanager get-secret-value --secret-id dev/snyk/token/snyk-api-token --query SecretString --output text | jq -r '.\"snyk-api-token\"'", returnStdout: true).trim()
                        sh "snyk test --token=${snykToken} --severity-threshold=high"
                    }   
                }
            }
        }
        
        stage('Docker Image Build') {
            steps {
                script {
                    // 1. Login to ECR (The modern way)
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        
                    // 2. Build the Docker Image
                    dir("${WORK_DIR}") {
                        sh "docker build --provenance=false -t ${env.FULL_IMAGE} ."
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    // If using the CLI to fetch manually (Option 1)
                    sh "trivy image --severity HIGH,CRITICAL --exit-code 1 ${env.FULL_IMAGE}"
                }
            }
        }

        stage('Push to ECR') {
            steps{
                script {
                    // 1. Login to ECR (The modern way)
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                    // 2. Tag the image with 'latest' as well
                    sh "docker tag ${env.FULL_IMAGE} ${AWS_ECR_REPO}/${ECR_REPO_NAME}:latest"

                    // 2. Push both tags to ECR
                    sh "docker push ${env.FULL_IMAGE}"
                    sh "docker push ${AWS_ECR_REPO}/${ECR_REPO_NAME}:latest"
                }
            }
        }
        
        stage('Package & Push Artifact') {
            steps {
                dir("${WORK_DIR}") {
                    script {
                        // Rename and upload so it's always 'app.war' in the cloud
                        // This stores it at: s3://shrinath-jenkins-artifacts/12/app.war
                        sh "aws s3 cp target/*.war s3://javawebapp-dev/${env.BUILD_NUMBER}/javawebapp.war"
                        sh "aws s3 cp target/*.war s3://javawebapp-dev/latest/javawebapp.war"
                        
                        echo "Artifact version ${env.BUILD_NUMBER} uploaded successfully as javawebapp.war"
                    }   
                }
            }
        }
    }
}
