#!/bin/bash
set -e

# Jenkins installation —
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y openjdk-17-jdk
java -version
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo ufw allow 8080
sudo ufw reload

echo "Jenkins installation complete."

# === Save SonarQube logic to boot script ===
sudo tee /usr/local/bin/sonarqube-full-setup.sh > /dev/null << 'EOF'
#!/bin/bash
set -e

LOGFILE="/var/log/sonar-full-install.log"
exec > >(tee -a "$LOGFILE") 2>&1

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $1"; }
run() { "$@" || { log "ERROR: Failed on: $*"; exit 1; } }

# Stage 1
if [ ! -f /var/log/sonar_stage1_done ]; then
  log "[*] Stage 1: System prep"
  run sudo hostnamectl set-hostname sonar-jenkins
  run sudo apt-get update -y
  run sudo apt-get upgrade -y
  echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
  echo "fs.file-max=65536" | sudo tee -a /etc/sysctl.conf
  echo "ulimit -n 65536" | sudo tee -a /etc/security/limits.conf
  echo "ulimit -u 4096" | sudo tee -a /etc/security/limits.conf
  touch /var/log/sonar_stage1_done
  reboot
  exit 0
fi

# Stage 2
if [ -f /var/log/sonar_stage1_done ] && [ ! -f /var/log/sonar_complete ]; then
  log "[*] Stage 2: Installing PostgreSQL, Java, SonarQube"
  run sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  run wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - &>/dev/null
  run sudo apt-get update -y
  run sudo apt-get install -y postgresql postgresql-contrib
  run sudo systemctl enable --now postgresql
  echo "postgres:sonar" | sudo chpasswd
  run sudo -u postgres createuser sonar
  run sudo -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'sonar';"
  run sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
  run sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"
  run sudo apt-get install -y openjdk-17-jdk openjdk-17-jre unzip
  run sudo wget -q https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.4.87374.zip -P /opt/
  run sudo unzip -q /opt/sonarqube-9.9.4.87374.zip -d /opt/
  run sudo rm /opt/sonarqube-9.9.4.87374.zip
  run sudo mv /opt/sonarqube-9.9.4.87374 /opt/sonarqube
  run sudo groupadd sonar
  run sudo useradd -c "sonar" -d /opt/sonarqube -g sonar sonar
  run sudo chown -R sonar:sonar /opt/sonarqube
  echo "sonar.jdbc.username=sonar" | sudo tee -a /opt/sonarqube/conf/sonar.properties
  echo "sonar.jdbc.password=sonar" | sudo tee -a /opt/sonarqube/conf/sonar.properties
  echo "sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube" | sudo tee -a /opt/sonarqube/conf/sonar.properties
  sudo tee /etc/systemd/system/sonar.service > /dev/null <<SERVICE
[Unit]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
[Install]
WantedBy=multi-user.target
SERVICE
  run sudo systemctl daemon-reexec
  run sudo systemctl enable --now sonar
  touch /var/log/sonar_complete
  log "[✓] SonarQube fully installed"
fi
EOF


sudo chmod +x /usr/local/bin/sonarqube-full-setup.sh

# === Install systemd service BEFORE reboot ===
sudo tee /etc/systemd/system/sonarqube-init.service > /dev/null <<EOF
[Unit]
Description=SonarQube full installer
After=network.target

[Service]
ExecStart=/usr/local/bin/sonarqube-full-setup.sh
Type=oneshot
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable sonarqube-init.service

# === Trigger the setup script ===
/usr/local/bin/sonarqube-full-setup.sh
