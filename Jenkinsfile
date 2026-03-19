pipeline {
    agent {label 'postgres'}

    tools {
        jdk 'jdk-21'
    }

    environment {
        GIT_REPO = "https://github.com/shrinathb05/webapp-java.git"
        GIT_BRANCH= "dev"

        // Ensure these match Manage Jenkins > Tools names exactly!
        SONAR_SERVER_NAME = 'sonar-server'
        OWASP_TOOL_NAME   = 'DP-Check'

        WAR_NAME    = "target/*.war"
        SCAN_REPORT = "target/dependency-check-report.xml"

        NVD_CRED_ID = 'nvd-api-key'
    }

    stages {
        
        stage('Checkout') {
            steps {
                deleteDir()
                git branch: "${env.GIT_BRANCH}", url: "${env.GIT_REPO}"
                sh "ls -lrt"
            }
        }
        
        stage('Build & Test') {
            steps {
                echo "Compiling and running the unit tests........"
                sh "mvn clean test"
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv("${SONAR_SERVER_NAME}") {
                    echo "Performing Static Code Analysis....."
                    sh "mvn sonar:sonar"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    echo "🚦 Waiting for Quality Gate..."
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "❌ Pipeline aborted: SonarQube Quality Gate failed (${qg.status})"
                        }
                    }
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_KEY')]) {
                    script {
                        dependencyCheck additionalArguments: '--scan ./ --out target --format HTML --format XML --nvdApiKey ' + NVD_KEY + ' --failOnCVSS 8',
                        odcInstallation: "${env.OWASP_TOOL_NAME}"
                    }
                }
            }
            post {
                always { 
                    dependencyCheckPublisher pattern: 'target/dependency-check-report.xml' 
                }
            }
        }

        stage('Package Artifact') {
            steps {
                echo "🏗️ Finalizing WAR package..."
                sh "mvn package -DskipTests"
            }
        }

        stage('Archive Artifact') {
            steps {
                echo "📦 Archiving build: ${env.WAR_NAME}"
                archiveArtifacts artifacts: "${env.WAR_NAME}", fingerprint: true
            }
        }

        stage('Docker Image Build') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-login', 
                        usernameVariable: 'USER', 
                        passwordVariable: 'PASS'
                    )]) {
                        echo "Docker image building........"
                        sh 'docker build -t shrinath05/project:javawebapp-0.3 .'

                        echo "Logging into dockerhub .........."
                        sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                    }    
                }
            }
        }
        
        stage('Image Push DockerHub') {
            steps {
                script {
                    echo "Pushing image to dockerhub......"
                    sh "docker push shrinath05/project:javawebapp-0.3"
                }
            }
        }
    }
}