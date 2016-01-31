VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Set some basic SSH values; not really needed but here for reference.
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  config.ssh.insert_key = "true"

  ########################################################################################
  # Defining 'sandbox'.
  ########################################################################################
  config.vm.define "sandbox", primary: true, autostart: true do |sandbox|

    # VirtualBox specific configuration options.
    sandbox.vm.provider :virtualbox do |vbox|
      vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vbox.customize ["modifyvm", :id, "--memory", 512]
      vbox.customize ["modifyvm", :id, "--cpus", 1]
      # vbox.customize ["modifyvm", :id, "--name", "Sandbox"]
      vbox.name = "Sandbox_UBUNTU_1404"
    end

    # Basic virtual machine configuration options.
    sandbox.vm.box = "ubuntu/trusty64"
    sandbox.vm.define "sandbox"
    sandbox.vm.hostname = "sandbox"
    sandbox.vm.box_check_update = false
    sandbox.vm.network "private_network", ip: "192.168.56.10"
    sandbox.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh"
    sandbox.vm.synced_folder ".", "/vagrant", type: "nfs", disabled: true

    # Copy over the configuration directory.
    # sandbox.vm.provision :file, source: "config_dir", destination: "config_dir"
    sandbox.vm.synced_folder "deployment_configs", "/home/vagrant/deployment_configs", type: "rsync", rsync__exclude: ".DS_Store"

    # Set the shell script to provision the server.
    sandbox.vm.provision :shell, :path => "provision.sh", :args => "deployment_configs vagrant sandbox sandbox.local"

  end

  ########################################################################################
  # Defining 'jabroni'.
  ########################################################################################
  config.vm.define "jabroni", primary: false, autostart: false do |sandbox|

    # VirtualBox specific configuration options.
    sandbox.vm.provider :virtualbox do |vbox|
      vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vbox.customize ["modifyvm", :id, "--memory", 512]
      vbox.customize ["modifyvm", :id, "--cpus", 1]
      # vbox.customize ["modifyvm", :id, "--name", "Jabroni"]
      vbox.name = "Jabroni_UBUNTU_1404"
    end

    # Basic virtual machine configuration options.
    sandbox.vm.box = "ubuntu/trusty64"
    sandbox.vm.define "jabroni"
    sandbox.vm.hostname = "jabroni"
    sandbox.vm.box_check_update = false
    sandbox.vm.network "private_network", ip: "192.168.56.20"
    sandbox.vm.network :forwarded_port, guest: 22, host: 2223, id: "ssh"
    sandbox.vm.synced_folder ".", "/vagrant", type: "nfs", disabled: true

    # Copy over the configuration directory.
    # sandbox.vm.provision :file, source: "config_dir", destination: "config_dir"
    sandbox.vm.synced_folder "deployment_configs", "/home/vagrant/deployment_configs", type: "rsync", rsync__exclude: ".DS_Store"

    # Set the shell script to provision the server.
    sandbox.vm.provision :shell, :path => "provision.sh", :args => "deployment_configs vagrant jabroni jabroni.local"

  end

end
