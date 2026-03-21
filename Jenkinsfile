pipeline {
    agent {label 'tomcat-agent'}
    
    parameters {
        string(name: "TAG_NAME", defaultValue: "v0.1", description: "Provide the tag name to proceed further....")
    }
    
    environment {
        LOG_DIR="/home/ubuntu/var/work/logs"
        //LOG_FILE="$LOG_DIR/deploy_$(date +'%Y%m%D_%H%M%S').log"
        WORK_DIR="/home/ubuntu/var/work/javawebapp"
        APP_NAME="maven-web-app"
        DEPLOY_DIR="/home/ubuntu/tomcat/webapps"
        BACKUP_DIR="/home/ubuntu/backup"
        GIT_REPO="https://github.com/shrinathb05/webapp-java.git"
    }
    
    stages {
        
        stage('Clean Working Directory') {
            steps {
                sh """
                    mkdir -p '${WORK_DIR}'
                    rm -rf '${WORK_DIR}'/*
                """
            }
        }
        
        stage('Checkout Artifacts') {
            steps {
                dir("${WORK_DIR}") {
                    script {
                        // Use credentials to avoid GitHub API rate limits
                        withCredentials([string(credentialsId: 'github-api-token', variable: 'GH_TOKEN')]) {
                            sh """
                                # 1. Ask the GitHub API for the Release metadata for this tag
                                # 2. Use 'jq' to find the download URL of any asset ending in .war
                                ASSET_URL=\$(curl -H "Authorization: token ${GH_TOKEN}" -s https://api.github.com/repos/shrinathb05/webapp-java/releases/tags/${params.TAG_NAME} | jq -r '.assets[] | select(.name | endswith(".war")) | .browser_download_url')
                                
                                if [ -z "\$ASSET_URL" ] || [ "\$ASSET_URL" == "null" ]; then
                                    echo "ERROR: No .war file found for tag ${params.TAG_NAME}"
                                    exit 1
                                fi

                                # 3. Download the actual file
                                echo "Downloading artifact from: \$ASSET_URL"
                                curl -H "Authorization: token ${GH_TOKEN}" -L -O "\$ASSET_URL"
                            """
                        }
                    }
                }
            }
        }
        
        stage('Stop Tomcat Service') {
            steps {
                script {
                    sh """
                        # Stop the tomcat service
                        sudo systemctl stop tomcat
                        
                        # Check the Status
                        CHECK_STATUS="sudo systemctl is-active --quiet tomcat"
                        
                        # Verify the tomcat is stopped or not
                        if ${env.CHECK_STATUS}; then
                            echo "The Tomcat service is still up and running..."
                            exit 1
                        else
                            echo "Tomcat service is successfully stopped."
                        fi
                    """
                }
            }
        }

        stage('Backup') {
            steps {
                script {
                    // Define the timestamp in Groovy
                    def timestamp = sh(script: "date +%Y%m%d%H%M%S", returnStdout: true).trim()
                    def warFile = "${DEPLOY_DIR}/${APP_NAME}.war"
                    def backupFile = "backup_${timestamp}.tar.gz"
                    
                    echo "Taking Backup of existing war file: ${warFile}"
        
                    if (fileExists(warFile)) {
                        echo "Found the WAR file, archiving..."
                        
                        sh """
                            tar -cvzf ${backupFile} -C ${DEPLOY_DIR} ${APP_NAME}.war
                            mv ${backupFile} ${BACKUP_DIR}/
                            rm -f ${warFile}
                        """
                        echo "Backup completed: ${BACKUP_DIR}/${backupFile}"
                    } else {
                        echo "File ${warFile} not found. Skipping backup."
                    }
                }
            }
        }
        
        stage('Deploy war') {
            steps {
                script {

                    def deployFile = "${DEPLOY_DIR}/${APP_NAME}.war"
                    def sourceFile = "${WORK_DIR}/${APP_NAME}.war"
                    sh """
                        # Check the APP directory exist or not and cleanup if exist
                        cd '${DEPLOY_DIR}'
                        if [ ! -d "${APP_NAME}" ];then
                            echo "The ${APP_NAME} directory does not exist"
                        else
                            echo "The ${APP_NAME} directory exist. Cleaning up...."
                            rm -rf '${APP_NAME}'
                        fi

                        # Deploying war file to webapps
                        if [ -f "${sourceFile}" ]; then
                            echo "File found. deploying......."
                            cp -r "${sourceFile}" "${DEPLOY_DIR}"
                        fi

                        # Verify the file successfully copied or not
                        if [ -f "${deployFile}" ]; then
                            echo "The ${deployFile} successfully copied to ${DEPLOY_DIR}."
                        else
                            echo "File not copied successfully..."
                            exit 1
                        fi
                    """
                }
            }
        }
        
        stage('Checksum') {
            steps {
                script {
                    def deployFile = "${DEPLOY_DIR}/${APP_NAME}.war"
                    def sourceFile = "${WORK_DIR}/${APP_NAME}.war"
                    
                    echo "Verifying file integrity..."
                    // 1. Calculate checksum of the source file
                    def sourceChecksum = sh(script: "sha256sum ${sourceFile} | awk '{print \$1}'", returnStdout: true).trim()
                    
                    // 2. Calculate checksum of the deployed file
                    def deployedChecksum = sh(script: "sha256sum ${deployFile} | awk '{print \$1}'", returnStdout: true).trim()
                    
                    echo "Source Checksum:   ${sourceChecksum}"
                    echo "Deployed Checksum: ${deployedChecksum}"
                    
                    // 3. Compare them
                    if (sourceChecksum == deployedChecksum) {
                        echo "✅ Success: Checksums match! The file was copied correctly."
                    } else {
                        error "❌ Critical Error: Checksum mismatch! The deployed file is corrupted or different."
                    }
                }
            }
        }
        
        stage('Start Tomcat Service') {
            steps {
                script {
                    sh """
                        echo "Starting Tomcat service..."
                        sudo systemctl start tomcat
                        
                        # Check the Status
                        CHECK_STATUS="sudo systemctl is-active --quiet tomcat"
                        
                        # 2. Give it a few seconds to initialize
                        echo "Waiting for service to stabilize..."
                        sleep 3
                        
                        # Verify the tomcat is stopped or not
                        if \$CHECK_STATUS; then
                            echo "✅ Tomcat service is successfully started"
                        else
                            echo "❌ Tomcat service not started."
                            sudo systemctl status tomcat --no-pager
                            sudo journalctl -u tomcat -n 20 --no-pager
                            exit 1
                        fi
                    """
                }
            }
        }
        
        stage('App Directory Verify') {
            steps {
                script {
                    sh """
                        # Check the APP directory exist or not
                        cd '${DEPLOY_DIR}'
                        if [ -d "${DEPLOY_DIR}/${APP_NAME}" ];then
                            echo "The ${APP_NAME} directory exist"
                        else
                            echo "The ${APP_NAME} directory does not exist"
                            exit 1
                        fi
                    """
                }
            }
        }
    }
}
