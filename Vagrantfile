Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.define "vagrant"
  config.vm.hostname = "vagrant"
  config.ssh.username = "vagrant"
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.synced_folder ".", "/vagrant", :disabled => true

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 512]
    v.customize ["modifyvm", :id, "--cpus", 1]
    # v.customize ["modifyvm", :id, "--name", "Vagrant"]
    v.name = "Vagrant (Ubuntu 14.04; Base)"
  end

  # Copy files from the Vagrant host to the Vagrant guest.
  config.vm.provision "file", source: "ipset.conf", destination: "ipset.conf"
  config.vm.provision "file", source: "iptables.conf", destination: "iptables.conf"
  config.vm.provision "file", source: "iptables-persistent-ipset.patch", destination: "iptables-persistent-ipset.patch"

  # Shell script to provision the server.
  config.vm.provision :shell, :path => "provision.sh"

end
