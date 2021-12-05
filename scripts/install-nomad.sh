#!/bin/bash
# This script will install Nomad on Ubuntu 20.4 TLS 
# Installation commands as per documentation link
# https://www.nomadproject.io/docs/install

echo "Install Nomad"
echo "$(date +"%x %r %z")"

# Add the HashiCorp GPG key.
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add the official HashiCorp Linux repository.
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update and install.
sudo apt-get install nomad

# check nomad version
nomad -version

echo "Installed Successfully"