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

        stage('5. Security: Dependency Scan') {
            steps {
                // Using the environment variable for the Credentials ID
                withCredentials([string(credentialsId: "${env.NVD_CRED_ID}", variable: 'NVD_KEY')]) {
                    script {
                        echo "🔍 Scanning 3rd party libraries for vulnerabilities..."
                        dependencyCheck additionalArguments: """
                            --scan ./ 
                            --out target 
                            --format HTML 
                            --format XML
                            --nvdApiKey ${NVD_KEY}
                            --failOnCVSS 7
                        """, odcInstallation: "${env.OWASP_TOOL_NAME}"
                    }
                }
            }
            post {
                always {
                    dependencyCheckPublisher pattern: "${env.SCAN_REPORT}"
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
    }

    post {
        success {
            echo "✅ SUCCESS: Project ${env.JOB_NAME} Build #${env.BUILD_NUMBER} passed all gates."
        }
        failure {
            echo "❌ FAILURE: Check Jenkins Console logs for Project ${env.JOB_NAME} Build #${env.BUILD_NUMBER}."
        }
    }
}
