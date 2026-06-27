@Library('shared@main') _
pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven'
        // SNYK_HOME = tool 'snyk'
    }

    environment {
        GIT_REPO = "https://github.com/shrinathb05/webapp-java.git"
        GIT_BRANCH = "main"

        SONAR_SERVER_NAME = "sonar-server"
        OWASP_TOOL_NAME = "owasp-dp-Check"

        WAR_NAME = "target/*.war"
        SCAN_REPORT = "target/dependency-check-report.xml"
        WORK_DIR = "/home/ubuntu/var/work/javawebapp"
        NVD_CRED_ID = 'nvd-api-key'

        APP_VERSION = "0.4" 
        IMAGE_NAME = "shrinath05/project:javawebapp-${APP_VERSION}"
    }

    stages {
        stage('Clean & Checkout') {
            steps {
                cleanWs()
                clone("https://github.com/shrinathb05/webapp-java.git","main")
                sh 'ls -lrt'
            }
        }

        stage('Build & Test') {
            steps {
                echo "Compiling and running the unit tests......."
                sh "mvn clean verify"
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv("${env.SONAR_SERVER_NAME}") {
                    echo "Performing sonarqube analysis for the code......"
                    sh "mvn sonar:sonar"
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

        stage('Snyk Vulnerability Scan') {
            steps {
                // Binds your secret token safely into an environment variable
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    script {
                        // 1. Install Snyk CLI globally on the agent node (if not already baked into the agent image)
                        sh 'npm install -g snyk'
                        
                        // 2. Run the security scan (example configurations below)
                        
                        // Option A: Scan open-source dependencies and fail only on high/critical issues
                        sh 'snyk test --severity-threshold=high'
                        
                        // Option B: Scan your application code (SAST)
                        // sh 'snyk code test'
                        
                        // Option C: Scan a newly built Docker container
                        // sh 'snyk container test myapp:latest --file=Dockerfile'
                    }
                }
            }
        }

        // stage('OWASP Dependency Check') {
        //     steps {
        //         withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_KEY')]) {
        //             script {
        //                 dependencyCheck additionalArguments: "--scan ./ --out target --format HTML --format XML --nvdApiKey ${NVD_KEY} --failOnCVSS 8",
        //                 odcInstallation: "${env.OWASP_TOOL_NAME}"
        //             }
        //         }
        //     }
        // }
    }
}