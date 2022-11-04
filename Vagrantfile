##########################################################################################
#
# Vagrantfile (Vagrantfile) (c) by Jack Szwergold
#
# Vagrantfile is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2016-01-27, js
# Version: 2016-01-27, js: creation
#          2016-02-01, js: development
#          2016-12-24, js: development
#
##########################################################################################

# Set the minmum required version of Vagrant.
Vagrant.require_version ">= 1.9.1"

# Set the Vagrant API version.
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with details for the Vagrant machines.
machines = YAML.load_file('machines.yaml')

# Where the magic happens.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Set some basic SSH values; not really needed but here for reference.
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  config.ssh.insert_key = false
  config.ssh.forward_agent = true
  vagrant_home_path = ENV["VAGRANT_HOME"] ||= "~/.vagrant.d"
  config.ssh.private_key_path = ["#{vagrant_home_path}/insecure_private_key", "~/.ssh/id_rsa"]
  config.vm.provision :shell, privileged: false do |shell_action|
    ssh_public_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    shell_action.inline = <<-SHELL
      echo #{ssh_public_key} >> /home/$USER/.ssh/authorized_keys
    SHELL
  end

  ########################################################################################
  # Define the machines.
  ########################################################################################
  machines.each do |settings|

    # Define the machine.
    config.vm.define "#{settings["hostname"]}", primary: settings["primary"], autostart: settings["autostart"] do |machine|

      # Set the username and password.
      config.ssh.username = "#{settings["username"]}"
      # config.ssh.password = "#{settings["password"]}"

      # config.ssh.insert_key = true
      # config.ssh.forward_agent = true

      # Print out the details of the configs.
      puts "Reading config for '#{settings["name"]}' (host: #{settings["hostname"]}, ip: #{settings["ip"]})"

      # VirtualBox specific configuration options.
      machine.vm.provider :virtualbox do |vbox|
        vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vbox.customize ["modifyvm", :id, "--memory", settings["memory"]]
        vbox.customize ["modifyvm", :id, "--cpus", settings["cpus"]]
        # vbox.customize ["modifyvm", :id, "--name", "#{settings["name"]}"]
        vbox.name = "#{settings["name"]}"
        vbox.gui = false
      end

      # Basic virtual machine configuration options.
      machine.vm.box = "#{settings["box"]}"
      machine.vm.hostname = "#{settings["hostname"]}"
      machine.vm.box_check_update = false
      machine.vm.network :private_network, ip: "#{settings["ip"]}", virtualbox__intnet: true

      # Set port forwarding.
      if settings["forward_guest1"].to_s.strip.length > 0
        machine.vm.network :forwarded_port, guest: settings["forward_guest1"], host: settings["forward_host1"], id: settings["forward_id1"], auto_correct: true
      end
      if settings["forward_guest2"].to_s.strip.length > 0
        machine.vm.network :forwarded_port, guest: settings["forward_guest2"], host: settings["forward_host2"], id: settings["forward_id2"], auto_correct: true
      end
      if settings["forward_guest3"].to_s.strip.length > 0
        machine.vm.network :forwarded_port, guest: settings["forward_guest3"], host: settings["forward_host3"], id: settings["forward_id3"], auto_correct: true
      end
      if settings["forward_guest4"].to_s.strip.length > 0
        machine.vm.network :forwarded_port, guest: settings["forward_guest4"], host: settings["forward_host4"], id: settings["forward_id4"], auto_correct: true
      end

      machine.vm.synced_folder ".", "/vagrant", type: "nfs", disabled: true

      # Copy over the deployment items directory.
      machine.vm.synced_folder "deploy_items", "/home/#{settings["username"]}/deploy_items", type: "rsync", rsync__exclude: [ ".DS_Store", ".gitignore", ".gitkeep" ]

      # Set the shell script to provision the server.
      if settings["provision_script"].to_s.strip.length > 0
        machine.vm.provision  :shell,
                              :privileged => true,
                              :path => settings["provision_script"],
                              env: {
                                "PROV_OS" => "#{settings['os']}",
                                "PROV_TIMEZONE" => "#{settings['timezone']}",
                                "PROV_HOSTNAME" => "#{settings['hostname']}.local",
                                "PROV_BANNER" => "#{settings['banner']}",
                                "PROV_BASICS" => "#{settings['basics']}",
                                "PROV_APACHE" => "#{settings['apache']}",
                                "PROV_MYSQL" => "#{settings['mysql']}",
                                "PROV_IMAGEMAGICK" => "#{settings['imagemagick']}",
                                "PROV_GEOIP" => "#{settings['geoip']}",
                                "PROV_IPTABLES" => "#{settings['iptables']}",
                                "PROV_FAIL2BAN" => "#{settings['fail2ban']}"
                              },
                              :args => "#{settings['username']} #{settings['password']}"
      end

      # Set the shell script to provision items for teh regular user.
      if settings["provision_script_regular"].to_s.strip.length > 0
        machine.vm.provision  :shell,
                              :privileged => false,
                              :path => settings["provision_script_regular"],
                              env: {
                                "PROV_OS" => "#{settings['os']}",
                                "PROV_TIMEZONE" => "#{settings['timezone']}",
                                "PROV_HOSTNAME" => "#{settings['hostname']}.local",
                                "PROV_BANNER" => "#{settings['banner']}",
                                "PROV_BASICS" => "#{settings['basics']}",
                                "PROV_APACHE" => "#{settings['apache']}",
                                "PROV_MYSQL" => "#{settings['mysql']}",
                                "PROV_IMAGEMAGICK" => "#{settings['imagemagick']}",
                                "PROV_GEOIP" => "#{settings['geoip']}",
                                "PROV_IPTABLES" => "#{settings['iptables']}",
                                "PROV_FAIL2BAN" => "#{settings['fail2ban']}"
                              },
                              :args => "#{settings['username']} #{settings['password']}"
      end

    end # config.vm.define

  end # machines.each

end
