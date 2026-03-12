pipeline {
    agent { label "node1"}

    environment {
    
        // Environment setup
        GIT_REPO    = "https://github.com/shrinathb05/webapp-java.git"
        GIT_BRANCH  = "release"

        // --- 2. Tool Names (Must match Jenkins Global Tool Config) ---
        // Ensure these match Manage Jenkins > Tools names exactly!
        SONAR_SERVER_NAME = 'SonarQube-Server'
        OWASP_TOOL_NAME   = 'owasp-dp-Check'

        // Paths and filenames
        WAR_NAME    = "target/*.war"
        SCAN_REPORT = "target/dependency-check-report.xml"

        // --- 4. Credentials IDs ---
        NVD_CRED_ID = 'nvd-api-key'
    
    }
    
    triggers {
        pollSCM('* * * * * ')
    }

    stages {

        stage('1. Checkout Code') {
            steps {
                deleteDir()
                git branch: "${env.GIT_BRANCH}", url: "${env.GIT_REPO}"
            }
        }

        stage('2. Build & Test') {
            steps {
                echo "Compiling and running unit tests......"
                sh "mvn clean test"
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('3. Sonarqube Analysis') {
            steps {
                // Using the environment variable for the server name
                withSonarQubeEnv("${env.SONAR_SERVER_NAME}") {
                    echo "Performing Static Code Analysis....."
                    sh "mvn sonar:sonar"
                }
            }
        }

        stage('4. Quality Gate') {
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

        stage('5. OWASP Dependency Check') {
            steps {
                withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_KEY')]) {
                    script {
                        // We use single quotes for the string to prevent Groovy interpolation
                        // and let the plugin/shell handle the variable safely.
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
        
        stage('6. Package Artifact') {
            steps {
                echo "🏗️ Finalizing WAR package..."
                sh "mvn package -DskipTests"
            }
        }

        stage('7. Archive Artifact') {
            steps {
                echo "📦 Archiving build: ${env.WAR_NAME}"
                archiveArtifacts artifacts: "${env.WAR_NAME}", fingerprint: true
            }
        }
        stage('8. Docker Build & Deploy') {
            steps {
                script {
                    // 1. Build the image using the .war from the 'target' folder
                    sh 'docker build -t shrinath05/project:javawebapp-0.1 .'

                    // 2. Stop and remove the old container if it's running
                    sh 'docker stop tomcatapp || true'
                    sh 'docker rm tomcatapp || true'

                    // 3. Run the new container
                    // Maps host port 8081 to Tomcat port 8080
                    sh 'docker run -d -p 8081:8080 --name tomcatapp shrinath05/project:javawebapp-0.1'
                }
            }
        }
    }

    // post {
    //     success {
    //         mail to: 'shrinath7028@gmail.com',
    //              subject: "✅ Deployment Successful: ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
    //              body: """Great news! The application was deployed successfully to Tomcat.
    //                       Build URL: ${env.BUILD_URL}
    //                       SonarQube: http://<SONAR_IP>:9000"""
    //     }
    //     failure {
    //         mail to: 'shrinath7028@gmail.com',
    //              subject: "❌ Deployment Failed: ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
    //              body: """The pipeline failed. Please check the logs immediately.
    //                       Build URL: ${env.BUILD_URL}"""
    //     }
    // }
}
