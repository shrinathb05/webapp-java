# change the jenkins url 
sudo nano /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml


Phase 1: Base Server Preparation

Step 1: System Tuning (Elasticsearch Setup)

SonarQube uses an internal search engine that will fail to start on a default Ubuntu setup because the memory and file limits are too low.

    Edit System Config:
    sudo nano /etc/sysctl.conf

    Add these lines to the very bottom:

    vm.max_map_count=524288
    fs.file-max=131072

    Apply the changes:
    sudo sysctl -p

Step 2: Install Java 21 JDK

As of early 2026, Java 21 is the minimum requirement.

    sudo apt update
    sudo apt install openjdk-21-jdk unzip wget -y

Step 3: Create the Sonar User

SonarQube is restricted from running as the root user for security.
    sudo useradd -m -d /opt/sonarqube -U -s /bin/bash sonarqube

Step 4: Download and Extract SonarQube

We will download the current Community Build.

    Go to the installation folder:
    cd /opt

    Download the latest package:
    sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip

    Unzip and move files:
    sudo unzip sonarqube-*.zip
    sudo mv sonarqube-10.4.1.88267/* /opt/sonarqube/
    sudo rm -rf sonarqube-10.4.1.88267 sonarqube-*.zip

    Give ownership to the sonar user:
    sudo chown -R sonarqube:sonarqube /opt/sonarqube

Step 5: Configure the Service

This creates a background service so SonarQube starts automatically.

    Create the file:
    sudo nano /etc/systemd/system/sonarqube.service

    Paste this exact configuration:
    [Unit]
    Description=SonarQube service
    After=syslog.target network.target

    [Service]
    Type=forking
    ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
    ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
    User=sonarqube
    Group=sonarqube
    Restart=always
    LimitNOFILE=131072
    LimitNPROC=8192

    [Install]
    WantedBy=multi-user.target

Step 6: Launch and Access

    Start the service:
    sudo systemctl daemon-reload
    sudo systemctl enable sonarqube
    sudo systemctl start sonarqube

    Verify it's running:
    sudo systemctl status sonarqube

Step 7. Common Fix: The Port Binding
    Open the properties file:
    sudo nano /opt/sonarqube/conf/sonar.properties

    Find and uncomment (remove the #) these lines:
    sonar.web.host=0.0.0.0
    sonar.web.port=9000

    Save and Restart:
    sudo systemctl restart sonarqube

Step 8. Check Ubuntu Firewall (UFW)
    sudo ufw status

Part 1: Cleanup the Failed Installation

Before we move to Docker, we need to wipe the old installation so it doesn't conflict with ports or consume RAM.

    Stop and Disable the service:
    Bash

    sudo systemctl stop sonarqube
    sudo systemctl disable sonarqube

    Remove the Systemd file:
    Bash

    sudo rm /etc/systemd/system/sonarqube.service
    sudo systemctl daemon-reload

    Delete the SonarQube files and user:
    Bash

    sudo rm -rf /opt/sonarqube
    sudo userdel sonarqube
    sudo rm -rf /home/sonarqube

    Kill any hanging Java processes:
    Bash

    sudo pkill -u sonarqube

Part 2: The "Practice-Ready" Docker Method

This is the fastest and most reliable way to get a successful pipeline running.
1. Install Docker (If not already installed)
Bash

sudo apt update
sudo apt install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# Log out and log back in, or run:
newgrp docker

2. Set the Kernel Limit (Mandatory for Docker too)

Elasticsearch inside Docker still needs this on the host:
Bash

sudo sysctl -w vm.max_map_count=524288

3. Run SonarQube Community Edition

Run this single command. It downloads the image and starts the server automatically.
Bash

docker run -d --name sonarqube \
    -p 9000:9000 \
    -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
    sonarqube:community

    -d: Runs in the background (detached).

    -p 9000:9000: Maps the port to your server.

    -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true: This forces it to skip the checks that were likely failing your manual install.

4. Verify it’s Running
Bash

docker logs -f sonarqube

Wait until you see: SonarQube is operational.

------------------------------------------------------------------------------------------
STEP 2
Great move. Using Docker for SonarQube is much more efficient for a DevOps lab environment—it gets the tool out of the way so you can focus on the actual pipeline logic.

Now that SonarQube is running, we need to connect your **Jenkins Master** to it. This allows Jenkins to send code to SonarQube and wait for the "Quality Gate" result (Stages 3 and 4 in your screenshot).

---

### **Step 1: Generate the SonarQube Token**
Jenkins needs a "password" (Token) to talk to SonarQube.

1.  Open your browser to `http://<Sonar-IP>:9000`.
2.  Log in (Default: `admin` / `admin`).
3.  Go to **My Account** (top right icon) > **Security**.
4.  Under **Generate Tokens**:
    * **Name:** `jenkins-token`
    * **Type:** `User Token`
    * Click **Generate**.
5.  **Copy this token immediately.** You won't see it again.

---

### **Step 2: Add the Token to Jenkins**
Now, go to your **Jenkins Master** web UI:

1.  Go to **Manage Jenkins** > **Credentials** > **System** > **Global credentials**.
2.  Click **Add Credentials**.
3.  **Kind:** `Secret text`.
4.  **Secret:** Paste the SonarQube token you just copied.
5.  **ID:** `sonar-token` (Remember this ID).
6.  Click **Create**.

---

### **Step 3: Install & Configure the SonarQube Plugin**
1.  In Jenkins, go to **Manage Jenkins** > **Plugins** > **Available Plugins**.
2.  Search for and install: **SonarQube Scanner**. (Restart Jenkins if prompted).
3.  Go to **Manage Jenkins** > **System**.
4.  Scroll down to **SonarQube servers**:
    * **Name:** `sonar-server` (Exact name is important for your Jenkinsfile).
    * **Server URL:** `http://<Your-Sonar-IP>:9000`
    * **Server authentication token:** Select `sonar-token` from the dropdown.
5.  Click **Save**.

---

### **Step 4: Configure the Scanner Tool**
Jenkins needs the actual "Scanner" binary to run the analysis.

1.  Go to **Manage Jenkins** > **Tools**.
2.  Scroll to **SonarQube Scanner installations**.
3.  Click **Add SonarQube Scanner**:
    * **Name:** `sonar-scanner`
    * Check **Install automatically**.
4.  Click **Save**.

---

### **Summary of Current Progress**
| Component | Status |
| :--- | :--- |
| **Jenkins Master** | Configured with Sonar Plugin & Credentials |
| **SonarQube (Docker)** | Running & Operational |
| **Agent Server** | Base Ubuntu ready |

### **Next Step**
Now we need to prepare your **Agent Server** (Worker Node). Since Stage 8 in your image is "**Docker Build & Deploy**", we need to install Docker on the Agent and connect it to the Jenkins Master.

**Would you like the commands to set up the SSH connection between the Master and the Agent now?**

--------------------------------------------------------------------------------------------------------------

STEP 3

Since we have the **Jenkins Master** and **SonarQube** talking to each other, the next critical step is setting up the **Agent Server (Worker Node)**. 

In your Stage View, steps like **Build & Test**, **OWASP Check**, and **Docker Build** should run on this Agent to keep your Master server clean and fast.

---

### **Step 1: Prepare the Agent Server**
Log into your **Agent Server** via terminal and install the tools required for your pipeline stages.

1.  **Install Java 17/21** (Required for Jenkins to communicate with the agent):
    ```bash
    sudo apt update
    sudo apt install openjdk-17-jdk -y
    ```
2.  **Install Docker** (Required for Stage 8: Docker Build & Deploy):
    ```bash
    sudo apt install docker.io -y
    sudo usermod -aG docker ubuntu
    newgrp docker
    ```
3.  **Install Node.js & NPM** (Required for Stage 2: Build & Test):
    ```bash
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    ```

---

### **Step 2: Connect Master to Agent (SSH Key)**
The Jenkins Master needs to "login" to the Agent automatically.

1.  **On Jenkins Master Server:**
    Generate a key if you don't have one:
    ```bash
    ssh-keygen -t rsa -b 4096
    ```
    (Press Enter for all defaults).
2.  **Copy the Key to Agent:**
    ```bash
    ssh-copy-id ubuntu@<AGENT_IP_ADDRESS>
    ```
3.  **Test the Connection:**
    Run `ssh ubuntu@<AGENT_IP_ADDRESS>`. If it logs in without a password, you are ready.

---

### **Step 3: Add the Agent in Jenkins UI**
1.  Go to **Jenkins Dashboard** > **Manage Jenkins** > **Nodes**.
2.  Click **New Node**.
    * **Node name:** `worker-1`
    * **Type:** `Permanent Agent`
3.  **Configure the Node:**
    * **Remote root directory:** `/home/ubuntu/jenkins`
    * **Labels:** `worker-node` (You will use this label in your Jenkinsfile).
    * **Launch method:** `Launch agents via SSH`.
    * **Host:** `<AGENT_IP_ADDRESS>`.
4.  **Credentials:**
    * Click **Add** > **Jenkins**.
    * **Kind:** `SSH Username with private key`.
    * **ID:** `agent-ssh`.
    * **Username:** `ubuntu`.
    * **Private Key:** Click "Enter directly" and paste the content of your Master's private key (`cat ~/.ssh/id_rsa`).
5.  **Host Key Verification:** Select `Non verifying Verification Strategy` (for lab environments).
6.  **Save** and click **Launch Agent**.

---

### **Step 4: Verify the Connection**
Once the node shows as "In sync" (not disconnected), your infrastructure is complete!

| Server | Status |
| :--- | :--- |
| **Jenkins Master** | Orchestrating |
| **SonarQube** | Waiting for scans |
| **Agent Server** | Connected & Ready to Build |

---

### **Next Step: The Pipeline Script**
Now we can finally create the **Pipeline Job**. We will write a `Jenkinsfile` that matches your 8 stages:
1.  Checkout
2.  Build/Test
3.  Sonar Scan
4.  Quality Gate
5.  OWASP Scan
6.  Package
7.  Archive
8.  Docker Deploy

**Would you like me to provide the full Jenkinsfile script for these 8 stages to test your setup?**

