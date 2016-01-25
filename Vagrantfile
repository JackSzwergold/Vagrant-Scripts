Vagrant.configure(2) do |config|

  # Basic configuration options.
  config.vm.box = "ubuntu/trusty64"
  config.vm.define "vagrant"
  config.vm.hostname = "vagrant"
  config.ssh.username = "vagrant"
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.synced_folder ".", "/vagrant", :disabled => true

  # VirtualBox specific configuration options.
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 512]
    v.customize ["modifyvm", :id, "--cpus", 1]
    # v.customize ["modifyvm", :id, "--name", "Vagrant"]
    v.name = "Vagrant (Ubuntu 14.04; Base)"
  end

  # Copy configuration files from the Vagrant host to the Vagrant guest.
  config.vm.provision "file", source: "config_files/ipset.conf", destination: "ipset.conf"
  config.vm.provision "file", source: "config_files/iptables.conf", destination: "iptables.conf"
  config.vm.provision "file", source: "config_files/iptables-persistent-ipset.patch", destination: "iptables-persistent-ipset.patch"
  config.vm.provision "file", source: "config_files/000-default.conf", destination: "000-default.conf"
  config.vm.provision "file", source: "config_files/common.conf", destination: "common.conf"
  config.vm.provision "file", source: "config_files/index.php", destination: "index.php"
  config.vm.provision "file", source: "config_files/apache2.conf", destination: "apache2.conf"
  config.vm.provision "file", source: "config_files/mpm_prefork.conf", destination: "mpm_prefork.conf"

  # Shell script to provision the server.
  config.vm.provision :shell, :path => "provision.sh"

end
