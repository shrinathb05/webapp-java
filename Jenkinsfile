@Library('shared@main') _
pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven'
        // SNYK_HOME = tool 'snyk'
        nodejs 'nodejs'
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
                withCredentials([snykToken(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    script {
                        // Download the official compiled standalone binary
                        sh 'curl --compressed https://static.snyk.io/cli/latest/snyk-linux -o snyk'
                        
                        // Make it executable
                        sh 'chmod +x ./snyk'
                        
                        // Run your scans using ./snyk instead of snyk
                        sh './snyk test --severity-threshold=high'
                        // Option B: Scan your application code (SAST)
                        sh 'snyk code test'
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