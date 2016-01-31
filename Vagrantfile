VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Set some basic SSH values; not really needed but here for reference.
  config.ssh.username = "vagrant"
  # config.ssh.password = "vagrant"
  config.ssh.insert_key = "true"

  ########################################################################################
  # Defining 'sandbox'.
  ########################################################################################
  config.vm.define "sandbox", primary: true, autostart: true do |machine|

    # Set some basic variables.
    vm_name = "Sandbox_UBUNTU_1404"
    vm_hostname = "sandbox"
    vm_ip = "192.168.56.10"
    vm_provision_lamp = "true"

    # VirtualBox specific configuration options.
    machine.vm.provider :virtualbox do |vbox|
      vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vbox.customize ["modifyvm", :id, "--memory", 512]
      vbox.customize ["modifyvm", :id, "--cpus", 1]
      # vbox.customize ["modifyvm", :id, "--name", "#{vm_name}"]
      vbox.name = "#{vm_name}"
    end

    # Basic virtual machine configuration options.
    machine.vm.box = "ubuntu/trusty64"
    machine.vm.hostname = "#{vm_hostname}"
    machine.vm.box_check_update = false
    machine.vm.network :private_network, ip: "#{vm_ip}"
    machine.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh"
    machine.vm.synced_folder ".", "/vagrant", type: "nfs", disabled: true

    # Copy over the configuration directory.
    # machine.vm.provision :file, source: "config_dir", destination: "config_dir"
    machine.vm.synced_folder "deployment_configs", "/home/vagrant/deployment_configs", type: "rsync", rsync__exclude: ".DS_Store"

    # Set the shell script to provision the server.
    machine.vm.provision :shell, :path => "provision.sh", :args => "deployment_configs #{config.ssh.username} #{machine.vm.hostname} #{machine.vm.hostname}.local #{vm_provision_lamp}"

  end

  ########################################################################################
  # Defining 'jabroni'.
  ########################################################################################
  config.vm.define "jabroni", primary: false, autostart: false do |machine|

    # Set some basic variables.
    vm_name = "Jabroni_UBUNTU_1404"
    vm_hostname = "jabroni"
    vm_ip = "192.168.56.20"
    vm_provision_lamp = "false"

    # VirtualBox specific configuration options.
    machine.vm.provider :virtualbox do |vbox|
      vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vbox.customize ["modifyvm", :id, "--memory", 512]
      vbox.customize ["modifyvm", :id, "--cpus", 1]
      # vbox.customize ["modifyvm", :id, "--name", "#{vm_name}"]
      vbox.name = "#{vm_name}"
    end

    # Basic virtual machine configuration options.
    machine.vm.box = "ubuntu/trusty64"
    machine.vm.hostname = "#{vm_hostname}"
    machine.vm.box_check_update = false
    machine.vm.network :private_network, ip: "#{vm_ip}"
    machine.vm.network :forwarded_port, guest: 22, host: 2223, id: "ssh"
    machine.vm.synced_folder ".", "/vagrant", type: "nfs", disabled: true

    # Copy over the configuration directory.
    # machine.vm.provision :file, source: "config_dir", destination: "config_dir"
    machine.vm.synced_folder "deployment_configs", "/home/vagrant/deployment_configs", type: "rsync", rsync__exclude: ".DS_Store"

    # Set the shell script to provision the server.
    machine.vm.provision :shell, :path => "provision.sh", :args => "deployment_configs #{config.ssh.username} #{machine.vm.hostname} #{machine.vm.hostname}.local #{vm_provision_lamp}"

  end

end
