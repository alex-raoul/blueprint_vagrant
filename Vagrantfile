# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

folder_name = (File.basename(File.dirname(__FILE__))).gsub("_","-")

DOMAIN = "#{folder_name}.vagrant"

SUBNET = "192.168.50"

# https://github.com/mitchellh/vagrant/issues/1673#issuecomment-34040409
$A_fix_tty = <<EOF
echo "Fix tty error"
(grep -q -E '^mesg n$' /root/.profile && sed -i 's/^mesg n$/tty -s \\&\\& mesg n/g' /root/.profile && echo 'Ignore the previous error about stdin not being a tty. Fixing it now...') || exit 0;
EOF

$B_install_puppet = <<EOF
echo "Install Puppet"
cd /tmp
wget --no-check-certificate -q https://apt.puppetlabs.com/puppetlabs-release-wheezy.deb
dpkg -i puppetlabs-release-wheezy.deb > /dev/null && echo 'Puppet repo added'
rm -f puppetlabs-release-wheezy.deb
apt-get update -q
apt-get install puppet -q -y > /dev/null && echo 'Puppet installed'
EOF

$C_blueprint_install = <<EOF
echo "Install Blueprint"
apt-get install python-pip git -q -y
pip install blueprint > /dev/null
git config --global user.email "nil"
git config --global user.name "nil"
EOF


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define :main do |vmconfig|
    vmconfig.vm.hostname = "main.#{DOMAIN}"

    vmconfig.vm.box = "chef/debian-7.4"

    vmconfig.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
      v.gui = false
    end

    vmconfig.vm.network "private_network", ip: "#{SUBNET}.10"
    vmconfig.vm.synced_folder "../myuglymodule/", "/opt/modules/myuglymodule/"
    vmconfig.vm.provision :shell, :inline => $A_fix_tty
    vmconfig.vm.provision :shell, :inline => $B_install_puppet
    vmconfig.vm.provision :shell, :inline => $C_blueprint_install
  end
end
