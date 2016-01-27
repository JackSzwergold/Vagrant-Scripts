Vagrant.configure(2) do |config|

  # VirtualBox specific configuration options.
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 512]
    v.customize ["modifyvm", :id, "--cpus", 1]
    # v.customize ["modifyvm", :id, "--name", "Vagrant"]
    v.name = "Vagrant (Ubuntu 14.04; Base)"
  end

  # Basic virtual machine configuration options.
  config.vm.box = "ubuntu/trusty64"
  config.vm.define "vagrant"
  config.vm.hostname = "vagrant"
  config.ssh.username = "vagrant"
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Copy over the configuration directory.
  # config.vm.provision :file, source: "config_dir", destination: "config_dir"
  config.vm.synced_folder "config_dir/", "/home/vagrant/config_dir", type: "rsync", rsync__exclude: ".DS_Store"

  # Set the shell script to provision the server.
  config.vm.provision :shell, :path => "provision.sh"

end
