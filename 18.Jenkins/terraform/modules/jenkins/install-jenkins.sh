#!/bin/bash

set -eux

apt-get update

apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  git \
  unzip

# Java 21
apt-get install -y openjdk-21-jre

# Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  -o /usr/share/keyrings/jenkins-keyring.asc

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list

apt-get update

apt-get install -y jenkins

systemctl enable jenkins
systemctl start jenkins