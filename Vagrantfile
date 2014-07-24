# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

folder_name = (File.basename(File.dirname(__FILE__))).gsub("_","-")

DOMAIN = "#{folder_name}.vagrant"

SUBNET = "192.168.50"

NODES=0

# https://github.com/mitchellh/vagrant/issues/1673#issuecomment-34040409
$A_fix_tty = <<EOF
echo "Fix tty error"
(grep -q -E '^mesg n$' /root/.profile && sed -i 's/^mesg n$/tty -s \\&\\& mesg n/g' /root/.profile && echo 'Ignore the previous error about stdin not being a tty. Fixing it now...') || exit 0;
EOF

$B_disable_ipv6 = <<EOF
echo "Disable IPv6"
echo "net.ipv6.conf.eth0.disable_ipv6 = 1" >> /etc/sysctl.conf > /dev/null
echo "net.ipv6.conf.eth1.disable_ipv6 = 1" >> /etc/sysctl.conf > /dev/null
sysctl -p
EOF


$C_change_debian_repo = <<EOF
echo "Change debian repo to france"
sed -i 's/mirrors.kernel.org/ftp.fr.debian.org/g' /etc/apt/sources.list
# apt-get update > /dev/null # uncomment if no puppet install 
EOF

$D_install_puppet = <<EOF
echo "Install puppet"
cd /tmp
wget --no-check-certificate -q https://apt.puppetlabs.com/puppetlabs-release-wheezy.deb
dpkg -i puppetlabs-release-wheezy.deb > /dev/null && echo 'Puppet repo added'
rm -f puppetlabs-release-wheezy.deb
apt-get update > /dev/null
apt-get install puppet -y > /dev/null && echo 'Puppet installed'
EOF

$E_install_puppet_modules = <<EOF
echo "Install puppet modules"
EOF

puppet_modules_to_install = []
puppet_modules_to_install.each do |m|
  $E_install_puppet_modules += "echo 'install #{m} module'; puppet module install #{m} | iconv -c -f utf-8 -t ascii\n"
end

$F_print_infos = <<EOF
echo "Hostname  : $(hostname)"
echo "FQDN      : $(hostname -f)"
echo "IP        : $(ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' | grep -v 127.0.0.1)"
echo "Uptime    : $(awk '{print $1}' /proc/uptime | cut -d. -f1)Secs"
echo "Cpu count : $(nproc)"
echo "Ram free  : $(cat /proc/meminfo | grep MemFree | awk '{print $2/1024}' | cut -d. -f1)/$(cat /proc/meminfo | grep MemTotal | awk '{print $2/1024}' | cut -d. -f1)Mb"
echo "Disk free : $(df -h|grep rootfs|awk '{print $4}'|cut -dG -f1)/$(df -h|grep rootfs|awk '{print $2}')"
EOF

$G_blueprint_install = <<EOF
apt-get install python-pip git -y
pip install blueprint
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
    
    vmconfig.vm.provision :shell, :inline => $A_fix_tty
    vmconfig.vm.provision :shell, :inline => $B_disable_ipv6
    vmconfig.vm.provision :shell, :inline => $C_change_debian_repo
    vmconfig.vm.provision :shell, :inline => $D_install_puppet
    vmconfig.vm.provision :shell, :inline => $E_install_puppet_modules
    vmconfig.vm.provision :shell, :inline => $G_blueprint_install
    vmconfig.vm.provision :shell, :inline => "blueprint create before"
    vmconfig.vm.provision :puppet
    vmconfig.vm.provision :shell, :inline => "blueprint create after"
    vmconfig.vm.provision :shell, :inline => "blueprint diff after before mydiff"
    vmconfig.vm.provision :shell, :inline => "blueprint show mydiff -P > a.pp"
    vmconfig.vm.provision :shell, :inline => "cat a.pp"
    vmconfig.vm.provision :shell, :inline => "puppet apply a.pp --noop"
    vmconfig.vm.provision :shell, :inline => $F_print_infos
  end

 NODES.times do |i|
    config.vm.define "node#{i}".to_sym do |vmconfig|
      vmconfig.vm.hostname = "node#{i}.#{DOMAIN}"

      vmconfig.vm.box = "chef/debian-7.4"

      vmconfig.vm.provider "virtualbox" do |v|
        v.memory = 512
        v.cpus = 1
        v.gui = false
      end

      vmconfig.vm.network "private_network", ip: "#{SUBNET}.%d" % (30 + i)
      
      vmconfig.vm.provision :shell, :inline => $A_fix_tty
      vmconfig.vm.provision :shell, :inline => $B_disable_ipv6
      vmconfig.vm.provision :shell, :inline => $C_change_debian_repo
      vmconfig.vm.provision :shell, :inline => $D_install_puppet
      vmconfig.vm.provision :shell, :inline => $E_install_puppet_modules
      vmconfig.vm.provision :puppet, :facter => { 'main_ip' => "#{SUBNET}.10"}
      vmconfig.vm.provision :shell, :inline => $F_print_infos
    end
  end
end
