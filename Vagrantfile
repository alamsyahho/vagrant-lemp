# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install required vagrant plugin
require File.dirname(__FILE__)+"/dependency_manager"
check_plugins ["vagrant-hostmanager", "vagrant-vbguest"]

class FixGuestAdditions < VagrantVbguest::Installers::RedHat
    def dependencies
        packages = super

        # If there's no "kernel-devel" package matching the running kernel in the
        # default repositories, then the base box we're using doesn't match the
        # latest CentOS release anymore and we have to look for it in the archives...
        if communicate.test('test -f /etc/centos-release && ! yum -q info kernel-devel-`uname -r` &>/dev/null')
            env.ui.warn("[#{vm.name}] Looking for the CentOS 'kernel-devel' package in the release archives...")
            packages.sub!('kernel-devel-`uname -r`', 'http://mirror.centos.org/centos' \
                                                     '/`grep -Po \'\b\d+\.[\d.]+\b\' /etc/centos-release`' \
                                                     '/{os,updates}/`arch`/Packages/kernel-devel-`uname -r`.rpm')
        end

        packages
    end
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Hostmanager configuration
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  # Vbguest configuration
  config.vbguest.installer = FixGuestAdditions

  # Seeking SA
  config.vm.define "app1", primary: true do |app1|
    app1.vm.box = "centos/7"
    app1.vm.hostname = 'app.local'
    app1.hostmanager.aliases = %w(app.local www.app.local)
    app1.vm.network "private_network", ip: "10.8.8.10", auto_network: true
    app1.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    app1.vm.synced_folder '.', '/vagrant', disabled: true
    #app1.vm.synced_folder ".", "/var/www/app1", :nfs => { :mount_options => ["dmode=777","fmode=777"] }
    app1.vm.synced_folder ".", "/var/www/app1/", type: "virtualbox", mount_options: ["dmode=777","fmode=777"]

    app1.vm.provider "virtualbox" do |vb|
      #vb.gui = true
      vb.customize ["modifyvm", :id, "--cpus", "2"]
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
  end

  # Shell provisioner
  config.vm.provision "bootstrap", type: "shell", :path => "deploy_ansible/bootstrap.sh"

  # Ansible provisioner
  config.vm.provision "build", type: "ansible_local" do |ansible|
    ansible.provisioning_path = "/var/www/app1"
    ansible.playbook = "deploy_ansible/build-vagrant.yml"
    ansible.inventory_path = "deploy_ansible/environments/vagrant/hosts"
    ansible.sudo = true
  end

end
