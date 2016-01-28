Vagrant.configure(2) do |config|

  # VirtualBox specific configuration options.
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--cpus", 2]
    # v.customize ["modifyvm", :id, "--name", "Vagrant"]
    v.name = "Sandbox_VAGRANT"
  end

  # Basic virtual machine configuration options.
  config.vm.box = "ubuntu/trusty64"
  config.vm.define "sandbox"
  config.vm.hostname = "sandbox"
  config.ssh.username = "vagrant"
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Copy over the configuration directory.
  # config.vm.provision :file, source: "config_dir", destination: "config_dir"
  config.vm.synced_folder "deployment_configs", "/home/vagrant/deployment_configs", type: "rsync", rsync__exclude: ".DS_Store"

  # Set the shell script to provision the server.
  config.vm.provision :shell, :path => "provision.sh", :args => "sandbox vagrant"

end
