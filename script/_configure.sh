#!/bin/bash
. $(dirname $0)/__functions.sh
HOST_DIR_NAME=$1

#Install packages here
sudo apt-get -y remove docker docker-engine docker.io containerd runc
sudo apt-get update

 sudo apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo rm /etc/apt/keyrings/docker.gpg

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
sudo usermod -aG docker ubuntu
sudo systemctl unmask docker
sudo systemctl enable docker
sudo systemctl start docker
group=docker

if [ $(id -gn) != $group ]; then
  exec sg $group "$0 $*"
fi


wget https://github.com/deviantony/docker-elk/archive/refs/tags/${DEVIANTONY_DOCKER_ELK_RELEASE}.tar.gz \
-O "docker-elk-${DEVIANTONY_DOCKER_ELK_RELEASE}.tar.gz" && \
tar -xzvf ./"docker-elk-${DEVIANTONY_DOCKER_ELK_RELEASE}.tar.gz" && \
mv docker-elk-${DEVIANTONY_DOCKER_ELK_RELEASE} docker-elk
rm ./"docker-elk-${DEVIANTONY_DOCKER_ELK_RELEASE}.tar.gz"
cp ${HOST_DIR_NAME}/env-elk-docker ${HOST_DIR_NAME}/docker-elk/.env
cd docker-elk
#export $(grep -v '^#' .env | xargs) && env && 
docker-compose down && docker-compose rm -f && docker-compose up -d

