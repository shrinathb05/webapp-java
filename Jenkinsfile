@Library('shared@main') _
pipeline {
    // agent {
    //     label 'agent'
    // }
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
                // Binds your secret token safely into an environment variable
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    script {
                        sh '''
                            # Install snyk and check if already there or not
                            if ! command -v snyk &> /dev/null; then
                                echo "Snyk not found. Installing..."
                                npm install -g snyk
                            else
                                echo "Snyk is already installed! Skipping installation."
                            fi
                        '''
                        
                        // 2. Run the security scan (example configurations below)
                        sh 'snyk test --scan-all-unmanaged --severity-threshold=high'
                        
                        // Option B: Scan your application code (SAST)
                        //sh 'snyk code test --include-ignores'
                    
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

        stage('Package Artifact') {
            steps {
                // Package Artifacts
                echo "🏗️ Finalizing WAR package..."
                sh "mvn package -DskipTests"
                    
                    // Archive Artifacts
                echo "📦 Archiving build: ${env.WAR_NAME}"
                archiveArtifacts artifacts: "${env.WAR_NAME}", fingerprint: true
            }
        }

        stage('Push Artifact Nexus') {
            steps {
                // Use withMaven to automatically handle your JDK, Maven installation, and settings.xml injection
                withMaven(
                    mavenSettingsConfig: 'f5e0f76c-c0a9-4b8d-8a4f-2570aea7f912', 
                    jdk: 'jdk21', 
                    maven: 'maven', 
                    traceability: true
                ) {
                    // Inject your credentials securely for Maven to intercept
                    withCredentials([usernamePassword(credentialsId: 'nexus-credentials-id', 
                                                    usernameVariable: 'NEXUS_USER', 
                                                    passwordVariable: 'NEXUS_PASSWORD')]) {
                        script {
                            // Just run clean deploy directly. Jenkins handles the settings injection automatically!
                            // sh 'mvn clean deploy -DskipTests'
                            def releaseVersion = "1.0.${env.BUILD_NUMBER}"
                            sh "mvn versions:set -DnewVersion=${releaseVersion}"
                            // sh 'mvn clean deploy -DskipTests -DaltDeploymentRepository=maven-snapshots::default::http://10.78.57.131:8081/repository/maven-snapshots/'
                            sh "mvn clean deploy -DskipTests -DaltDeploymentRepository=maven-releases::default::http://10.78.57.131:8081/repository/maven-releases/"
                        }
                    }
                }
            }
        }
    }

    post {
            success {
                emailtext(
                    mail to: 'shrinath7028@gmail.com',
                     subject: "SUCCESS: Jenkins Build #${env.BUILD_NUMBER} - ${env.JOB_NAME}",
                     body: """Team,
    
                    The pipeline completed successfully!
                    
                    --------------------------------------------------
                    BUILD DETAILS
                    --------------------------------------------------
                    Job Name:      ${env.JOB_NAME}
                    Build Number:  #${env.BUILD_NUMBER}
                    Artifact:      01-maven-web-app
                    Version:       1.0.${env.BUILD_NUMBER}
                    Nexus Status:  Uploaded successfully to maven-releases
                    Build URL:     ${env.BUILD_URL}
                    
                    Regards,
                    Jenkins CI/CD Automation
                    """,
                    attachLog: true
                )
            }
            
            failure {
                emailtext(
                    mail to: 'shrinath7028@gmail.com',
                         subject: "FAILURE: Jenkins Build #${env.BUILD_NUMBER} - ${env.JOB_NAME}",
                         body: """Team,
            
                    The pipeline build has FAILED.
                    
                    --------------------------------------------------
                    FAILURE DETAILS
                    --------------------------------------------------
                    Job Name:      ${env.JOB_NAME}
                    Build Number:  #${env.BUILD_NUMBER}
                    Log URL:       ${env.BUILD_URL}console
                    
                    Please check the console logs to investigate the failure.
                    
                    Regards,
                    Jenkins CI/CD Automation
                """,
                attachLog: true
            )
        }
        
        always {
            echo "Cleaning up the Jenkins build workspace..."
            // This wipes out the build workspace directory on the execution agent
            // cleanWs() 
        }
    }
}
