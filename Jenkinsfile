pipeline {
    agent { label 'slave-agent' }

    tools {
        jdk 'jdk-21'
        maven '3.9.12'
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
                    sh "mvn clean test"
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

        stage('OWASP Dependecy Check') {
            steps {
                dir("${WORK_DIR}") {
                    withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_KEY')]) {
                        script {
                            dependencyCheck additionalArguments: "--scan ./ --out target --format HTML --format XML --nvdApiKey ${NVD_KEY} --failOnCVSS 8",
                            odcInstallation: "${env.OWASP_TOOL_NAME}"
                        }
                    }
                }
            }
            post {
                always {
                    dir("${WORK_DIR}") {
                        dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                    }
                }
            }
        }
        
        stage('Package & Archive Artifacts') {
            steps {
                dir("${WORK_DIR}") {
                    
                    // Package Artifacts
                    echo "🏗️ Finalizing WAR package..."
                    sh "mvn package -DskipTests"
                    
                    // Archive Artifacts
                    echo "📦 Archiving build: ${env.WAR_NAME}"
                    archiveArtifacts artifacts: "${env.WAR_NAME}", fingerprint: true
                }
            }
        }
        
        stage('Docker Build Image') {
            steps {
                dir("${WORK_DIR}") {
                    script {
                        withCredentials([usernamePassword(
                        credentialsId: 'docker_token', 
                        usernameVariable: 'USER', 
                        passwordVariable: 'PASS'
                    )]) {
                            sh """
                                echo "Docker image building........"
                                docker build -t ${env.IMAGE_NAME} .
                                
                                echo "Logging into dockerhub .........."
                                echo $PASS | docker login -u $USER --password-stdin
                            """
                        }
                    }
                }
            }
        }
        
        stage('Docker Image Scan') {
            steps {
                dir("${WORK_DIR}") {
                    // --exit-code 1 tells Jenkins to FAIL the build if vulnerabilities are found
                    // --severity CRITICAL ensures we only stop for the worst bugs
                    sh "trivy image --exit-code 1 --severity CRITICAL ${env.IMAGE_NAME}"
                }
            }
        }
        
        stage('Docker Image Push') {
            steps {
                dir("${WORK_DIR}") {
                    script {
                        withCredentials([usernamePassword(
                        credentialsId: 'docker_token', 
                        usernameVariable: 'USER', 
                        passwordVariable: 'PASS'
                    )]) {
                            sh """
                                echo "Pushing image to dockerhub......"
                                docker push ${env.IMAGE_NAME}
                                
                                # It removes all images that are not being used by a running container
                                docker image prune -a -f
                                docker logout
                            """
                        }  
                    }
                }
            }
        }
        
        stage('cleanup') {
            steps {
                dir("${WORK_DIR}") {
                    sh "rm -rf ./*"
                    sh "ls -lrt"
                }
            }
        }
    }
    
    post {
        success {
            emailext (
                subject: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build successful! Check it here: ${env.BUILD_URL}",
                to: 'email123@gmail.com' // CHANGE THIS
            )
        }
        failure {
            emailext (
                subject: "FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Pipeline failed. Check the logs: ${env.BUILD_URL}",
                to: 'semail123@gmail.com' // CHANGE THIS
            )
        }
    }
}
