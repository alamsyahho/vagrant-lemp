#!/bin/bash

echo "Install EPEL repos"
if grep 7 /etc/redhat-release; then
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
elif grep 6 /etc/redhat-release; then
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
fi

echo "Install ansible and git"
yum -y install ansible git

sed -i 's/.*StrictHostKeyChecking.*/StrictHostKeyChecking\ no/g' /etc/ssh/ssh_config

#if [ ! -f ~/.ssh/id_rsa ]; then
#  echo "Generate ssh key"
#  ssh-keygen -N "" -t rsa -f ~/.ssh/id_rsa
#  cat ~/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
#fi

echo "Installing ansible roles"
ansible-galaxy install --force -r /var/www/app1/deploy_ansible/requirements.yml
