#!/bin/bash
# ===============LICENSE_START=======================================================
# Acumos Apache-2.0
# ===================================================================================
# Copyright (C) 2017-2020 AT&T Intellectual Property & Tech Mahindra.
# All rights reserved.
# ===================================================================================
# This Acumos software file is distributed by AT&T and Tech Mahindra
# under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# This file is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===============LICENSE_END=========================================================
#
# Name: 0b-depends.sh - z2a 0-kind/0b-depends setup script
#
# Prerequisites:
# - Ubuntu Xenial (16.04), Bionic (18.04), or Centos 7 VM
#
# - It is assumed, that the user running this script:
#		- has sudo access on the VM
#
# Usage:

# Anchor Z2A_BASE value
HERE=$(realpath $(dirname $0))
Z2A_BASE=$(realpath $HERE/..)
# Source the z2a utils file
source $Z2A_BASE/z2a-utils.sh
# Load user environment
load_env
# Redirect stdout/stderr to log file
redirect_to $HERE/0b-depends-install.log
# Exit with an error on any non-zero return code
trap 'fail' ERR

# Distribution ID
rhel || ubuntu || { log "Sorry, only Centos/RHEL or Ubuntu are currently supported." ; exit 1 ; }

log "Starting Phase 0b-depends (Distribution Specific Dependencies) installation ...."
# Installation - Phase 0b Distribution-specific setup
# source $Z2A_BASE/distro-setup/setup-distro.sh

# Determine the end-user actual GID
[[ -z GID ]] && GID=$(id -rg) ; export GID

# check & create /usr/local/bin (binary dependencies installation location)
sudo mkdir -p /usr/local/bin
sudo chown root:root /usr/local/bin
sudo chmod 755 /usr/local/bin

log "Adding EPEL repo ...."
# Add EPEL repo to RHEL/Centos
rhel && {
	rpm -qa | grep -q epel-release ||
		sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	sudo yum -y update
}

log "Adding miscellaneous prerequisites ...."
# RHEL/Centos Distribution misc. requirements
rhel && sudo yum install -y --setopt=skip_missing_names_on_install=False \
	yum-utils device-mapper-persistent-data lvm2 git jq make socat
# Ubuntu Distribution misc. requirements
ubuntu && sudo apt-get update -y && sudo apt-get install -y apt-transport-https ca-certificates \
	curl gnupg-agent software-properties-common git jq make socat

log "Installing yq - portable command-line YAML parser ...."
# RHEL/Centos and Ubuntu are the same
sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64
sudo chmod 755 /usr/local/bin/yq

log "Setting resources limits ...."
rhel && {
  cat <<EOF | sudo tee -a /etc/sysctl.d/98-inotify.conf
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
EOF
	sudo systemctl --system
}

ubuntu && {
	cat <<EOF | sudo tee -a /etc/sysctl.conf
# Local Modifications
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
EOF
	sudo systemctl -p /etc/sysctl.conf
}

log "Installing kubectl binary ...."
# Download and install kubectl
K8S_RELEASE=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
sudo curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$K8S_RELEASE/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl & sudo chown root:root /usr/local/bin/kubectl

log "Installing Helm v3 ...."
# Download and install helm v3 (to /usr/local/bin)
HELM_RELEASE=$(curl -Ls https://github.com/helm/helm/releases| awk '$0 ~ pat {print gensub(/.*".*\/(.*)".*/, "\\1","g");exit}' pat='href="/helm/helm/releases/tag/v3')
sudo curl -s https://get.helm.sh/helm-${HELM_RELEASE}-linux-amd64.tar.gz | tar -zxO linux-amd64/helm > /tmp/helm
sudo chmod +x /tmp/helm && sudo chown root:root /tmp/helm
sudo mv /tmp/helm /usr/local/bin/helm

log "Installing kind (Kubernetes in Docker) ...."
# Download and install kind (kubernetes in docker)
# kind is NOT DESIGNED FOR PRODUCTION ENVIRONMENTS
sudo curl -Lo /tmp/kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64"
sudo chmod +x /tmp/kind && sudo chown root:root /tmp/kind
sudo mv /tmp/kind /usr/local/bin/kind

log "Starting Phase 0b (Docker Community Edition) installation ...."
# Installation - Phase 1a  Docker Community Edition
# source $Z2A_BASE/distro-setup/setup-docker.sh

log "Removing old Docker versions ...."
# Remove old Docker versions (just in case) ; ignore if package does not exist
rhel && sudo yum remove docker docker-client docker-client-latest \
	docker-common docker-latest docker-latest-logrotate docker-logrotate \
	docker-engine || true
ubuntu && sudo apt-get remove docker docker-engine docker.io containerd runc || true

log "Setting up Docker-CE repositories ...."
# Setup Docker-CE repo
rhel && sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
ubuntu && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
	&& sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

log "Setting up Docker Community-Edition ...."
# Install Docker-CE
rhel && sudo yum -y install docker-ce docker-ce-cli containerd.io
ubuntu && sudo apt-get -y update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io

log "Creating /etc/docker directory ...."
## Create /etc/docker directory.
sudo mkdir -p /etc/docker

log "Creating /etc/docker/daemon.json file ...."
# Setup Docker daemon.
rhel && {
	cat <<EOF | sudo tee /etc/docker/daemon.json
{
	"exec-opts": ["native.cgroupdriver=systemd"],
	"log-driver": "json-file",
"log-opts": {
  	"max-size": "100m"
	},
	"storage-driver": "overlay2",
	"storage-opts": ["overlay2.override_kernel_check=true"]
	}
EOF
}

ubuntu && {
	cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
	}
EOF
}

log "Creating the systemd docker.service directory ...."
# Create the systemd docker.service directory
sudo mkdir -p /etc/systemd/system/docker.service.d

# Setup Docker daemon proxy entries.
PROXY_CONF=$Z2A_BASE/distro-setup/proxy.txt
[[ -f $PROXY_CONF ]] && {
	PROXY=$(<$PROXY_CONF) ;
	log "Configuring /etc/systemd/system/docker.service.d/http-proxy.conf file ...."
	cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://$PROXY"
Environment="HTTPS_PROXY=https://$PROXY"
Environment="NO_PROXY=127.0.0.1,localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
EOF
}

log "Starting Docker service ...."
# Start docker service
sudo systemctl daemon-reload
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl show --property=Environment docker

log "Adding USER to docker group ...."
# Add default user to the 'docker' group
sudo usermod -aG docker $USER

# We need to log out and back in at this point.
log "Docker has been installed on this host."
log "Host / VM preparation has been completed."
log "Please log out of this session and log back in to continue."
log "After login, please navigate to the ~/z2a/0-kind script directory and run 0c-cluster.sh."
log ""