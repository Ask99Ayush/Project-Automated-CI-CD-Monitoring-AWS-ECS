#!/bin/bash
set -euo pipefail

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y \
ca-certificates \
curl \
gnupg \
lsb-release \
unzip \
fontconfig

sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker "$USER"

cd /tmp
curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install || sudo ./aws/install --update
rm -rf /tmp/aws /tmp/awscliv2.zip

sudo apt install -y openjdk-21-jre

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /etc/apt/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins

sudo usermod -aG docker jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

docker --version
aws --version
java -version
systemctl status jenkins --no-pager

echo "DONE. REBOOT REQUIRED."
