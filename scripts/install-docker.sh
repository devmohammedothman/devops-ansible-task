#!/bin/bash

echo "Install Docker"
echo "$(date +"%x %r %z")"
FILE=/usr/share/keyrings/docker-archive-keyring.gpg

if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
  # Add Docker GPG apt Key
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
fi

# set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

echo "Installed Successfully"
