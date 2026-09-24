#!/bin/bash

set -eux

apt-get update

apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  git \
  unzip \
  jq \
  python3

# Java 21
apt-get install -y openjdk-21-jre

# =========================================================
# Docker
# =========================================================

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update

apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

systemctl enable docker
systemctl start docker

# =========================================================
# Jenkins
# =========================================================

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  -o /usr/share/keyrings/jenkins-keyring.asc

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list

apt-get update

apt-get install -y jenkins

# Jenkins -> Docker
usermod -aG docker jenkins

systemctl enable jenkins
systemctl start jenkins

# =========================================================
# Node.js 22
# =========================================================

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

apt-get install -y nodejs

# =========================================================
# Terraform
# =========================================================

TERRAFORM_VERSION="1.16.4"

curl -fsSL \
  "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  -o /tmp/terraform.zip

unzip -o /tmp/terraform.zip -d /usr/local/bin/

rm -f /tmp/terraform.zip

# =========================================================
# AWS CLI v2
# =========================================================

curl -fsSL \
  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o /tmp/awscliv2.zip

rm -rf /tmp/aws

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install --update

rm -rf /tmp/aws /tmp/awscliv2.zip

# =========================================================
# Restart Jenkins after Docker group change
# =========================================================

systemctl restart jenkins

# =========================================================
# Verification
# =========================================================

java -version
docker --version
node --version
npm --version
terraform version
aws --version
git --version
jq --version

echo "Jenkins installation completed successfully."