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
  config.vm.synced_folder ".", "/vagrant", :disabled => true

  # Copy over the environment related config files.
  config.vm.provision "file", source: "config_files/selected_editor", destination: ".selected_editor"

  # Copy over the IPTables and IPSet related config files.
  config.vm.provision "file", source: "config_files/ipset.conf", destination: "ipset.conf"
  config.vm.provision "file", source: "config_files/iptables.conf", destination: "iptables.conf"
  config.vm.provision "file", source: "config_files/iptables-persistent-ipset.patch", destination: "iptables-persistent-ipset.patch"

  # Copy over the Apache related config files.
  config.vm.provision "file", source: "config_files/000-default.conf", destination: "000-default.conf"
  config.vm.provision "file", source: "config_files/common.conf", destination: "common.conf"
  config.vm.provision "file", source: "config_files/index.php", destination: "index.php"
  config.vm.provision "file", source: "config_files/apache2.conf", destination: "apache2.conf"
  config.vm.provision "file", source: "config_files/mpm_prefork.conf", destination: "mpm_prefork.conf"

  # Copy over the MySQL related config files.
  config.vm.provision "file", source: "config_files/000-default.conf", destination: "000-default.conf"
  config.vm.provision "file", source: "config_files/mysql_secure_installation.sql", destination: "mysql_secure_installation.sql"

  # Copy over the Munin related config files.
  config.vm.provision "file", source: "config_files/apache-munin.conf", destination: "apache-munin.conf"
  config.vm.provision "file", source: "config_files/munin.conf", destination: "munin.conf"

  # Copy over the phpMyAdmin related config files.
  config.vm.provision "file", source: "config_files/apache-phpmyadmin.conf", destination: "apache-phpmyadmin.conf"

  # Set the shell script to provision the server.
  config.vm.provision :shell, :path => "provision.sh"

end
