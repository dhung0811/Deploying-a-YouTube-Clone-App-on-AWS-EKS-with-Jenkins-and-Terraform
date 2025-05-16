#!/bin/bash
set -e

# install jenkins
sudo apt-get update
sudo apt upgrade
sudo apt install openjdk-17-jdk -y
java -version
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins
sudo ufw allow 8080
sudo ufw reload
sudo ufw status

# Install SonarQube
#sudo useradd -m -d /opt/sonarqube sonarqube
#cd /opt
#sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip
#sudo unzip sonarqube-10.4.1.88267.zip
#sudo mv sonarqube-10.4.1.88267 sonarqube
#sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Start SonarQube
#sudo -u sonarqube nohup /opt/sonarqube/bin/linux-x86-64/sonar.sh start &

echo "Jenkins and SonarQube installation complete."