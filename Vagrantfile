VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Set some basic SSH values; not really needed but here for reference.
  config.ssh.username = "vagrant"
  # config.ssh.password = "vagrant"
  config.ssh.insert_key = "true"

  ########################################################################################
  # Details for the Vagrant machines.
  ########################################################################################
  vagrant_machines = {
    "Sandbox_UBUNTU_1404" => {
      :hostname => "sandbox",
      :ip => "192.168.56.10",
      :lamp => true,
      :ssh_guest => 22,
      :ssh_host => 2222,
      :memory => 512,
      :cpus => 1
    },
    "Jabroni_UBUNTU_1404" => {
      :hostname => "jabroni",
      :ip => "192.168.56.20",
      :lamp => false,
      :ssh_guest => 22,
      :ssh_host => 2223,
      :memory => 512,
      :cpus => 1
    }
  }

  ########################################################################################
  # Define the machines.
  ########################################################################################
  vagrant_machines.each do |machine_name, machine_details|

    puts "Setting config for '#{machine_name}' (host: #{machine_details[:hostname]}, ip: #{machine_details[:ip]})"

    config.vm.define "#{machine_details[:hostname]}", primary: true, autostart: true do |machine|

      # VirtualBox specific configuration options.
      machine.vm.provider :virtualbox do |vbox|
        vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vbox.customize ["modifyvm", :id, "--memory", machine_details[:memory]]
        vbox.customize ["modifyvm", :id, "--cpus", machine_details[:cpus]]
        # vbox.customize ["modifyvm", :id, "--name", "#{machine_name}"]
        vbox.name = "#{machine_name}"
      end

      # Basic virtual machine configuration options.
      machine.vm.box = "ubuntu/trusty64"
      machine.vm.hostname = "#{machine_details[:hostname]}"
      machine.vm.box_check_update = false
      machine.vm.network :private_network, ip: "#{machine_details[:ip]}"
      machine.vm.network :forwarded_port, guest: machine_details[:ssh_guest], host: machine_details[:ssh_host], id: "ssh"
      machine.vm.synced_folder ".", "/vagrant", type: "nfs", disabled: true

      # Copy over the configuration directory.
      # machine.vm.provision :file, source: "config_dir", destination: "config_dir"
      machine.vm.synced_folder "deployment_configs", "/home/vagrant/deployment_configs", type: "rsync", rsync__exclude: ".DS_Store"

      # Set the shell script to provision the server.
      machine.vm.provision :shell, :path => "provision.sh", :args => "deployment_configs #{config.ssh.username} #{machine.vm.hostname} #{machine.vm.hostname}.local #{machine_details[:lamp]}"

    end # config.vm.define

  end # machines.each

end
