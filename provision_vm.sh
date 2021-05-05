#!/bin/bash

# Define title function for annotating the script
title() {
    local TITLE="${@}"
    let "TITLE_LENGTH = ${#TITLE} + 4"
    local TITLE_SEPARATOR="$(printf '#%.0s' $(seq ${TITLE_LENGTH}))"
    printf "\n${TITLE_SEPARATOR}\n# ${TITLE} #\n${TITLE_SEPARATOR}\n"
    echo
}


title "Install apt packages to Support HTTPS"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

title "Install Docker"
echo "Adding Docker GPG Key to keyring"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Registering stable Docker Repository"
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Retrieving Docker Packages"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "Verify Docker is installed correctly"
docker run hello-world
if [  $? -eq 0  ]
then
    echo "Docker has successfully been installed, removing installed test image"
    docker rmi -f $(docker images -a -q)
else
    echo "Docker has not successfully been installed, exiting..."
    exit 1
fi

echo "Adding vagrant user to docker group"
usermod -a -G docker vagrant

title "Update All Installed Packages"
apt update
apt upgrade -y

echo "Restarting VM"
shutdown -r now