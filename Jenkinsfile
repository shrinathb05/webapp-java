@Library('shared@main') _
pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven'
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
    }
}