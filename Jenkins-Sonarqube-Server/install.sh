#!/bin/bash
set -e

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk wget gnupg unzip

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install SonarQube
sudo useradd -m -d /opt/sonarqube sonarqube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip
sudo unzip sonarqube-10.4.1.88267.zip
sudo mv sonarqube-10.4.1.88267 sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Start SonarQube
sudo -u sonarqube nohup /opt/sonarqube/bin/linux-x86-64/sonar.sh start &

echo "Jenkins and SonarQube installation complete."