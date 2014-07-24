# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "chef/debian-7.4"

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
  end

  config.vm.provision "shell", inline: "sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile"

# ipv6 support is buggy in my network
  config.vm.provision "shell", path: "scripts/0_disable_ipv6.sh"

# change mirror to france
  config.vm.provision "shell", path: "scripts/1_change_debian_repo.sh"

  config.vm.network "private_network", ip: "192.168.50.52"
end
