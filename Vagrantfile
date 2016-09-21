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
#
##########################################################################################

# Set the minmum required version of Vagrant.
Vagrant.require_version ">= 1.8.1"

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
  config.ssh.username = "vagrant"
  # config.ssh.password = "vagrant"
  config.ssh.insert_key = true

  ########################################################################################
  # Define the machines.
  ########################################################################################
  machines.each do |machine_settings|

    # Define the machine.
    config.vm.define "#{machine_settings["hostname"]}", primary: machine_settings["primary"], autostart: machine_settings["autostart"] do |machine|

      # Print out the details of the configs.
      puts "Reading config for '#{machine_settings["name"]}' (host: #{machine_settings["hostname"]}, ip: #{machine_settings["ip"]})"

      # VirtualBox specific configuration options.
      machine.vm.provider :virtualbox do |vbox|
        vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vbox.customize ["modifyvm", :id, "--memory", machine_settings["memory"]]
        vbox.customize ["modifyvm", :id, "--cpus", machine_settings["cpus"]]
        # vbox.customize ["modifyvm", :id, "--name", "#{machine_settings["name"]}"]
        vbox.name = "#{machine_settings["name"]}"
      end

      # Basic virtual machine configuration options.
      machine.vm.box = "ubuntu/trusty64"
      machine.vm.hostname = "#{machine_settings["hostname"]}"
      machine.vm.box_check_update = false
      machine.vm.network :private_network, ip: "#{machine_settings["ip"]}"
      machine.vm.network :forwarded_port, guest: machine_settings["ssh_guest"], host: machine_settings["ssh_host"], id: "ssh"
      machine.vm.synced_folder ".", "/vagrant", type: "nfs", disabled: true

      # Copy over the deployment configs directory.
      # machine.vm.provision :file, source: "config_dir", destination: "config_dir"
      machine.vm.synced_folder "deployment_configs", "/home/vagrant/deployment_configs", type: "rsync", rsync__exclude: [ ".DS_Store", ".gitignore", ".gitkeep" ]

      # Copy over the deployment DBs directory.
      # machine.vm.provision :file, source: "config_dir", destination: "config_dir"
      machine.vm.synced_folder "deployment_dbs", "/home/vagrant/deployment_dbs", type: "rsync", rsync__exclude: [ ".DS_Store", ".gitignore", ".gitkeep" ]

      # Set the shell script to provision the server.
      if machine_settings["provision_script"].to_s.strip.length > 0
        machine.vm.provision :shell, :path => machine_settings["provision_script"], :args => "#{machine_settings["deployment_configs_path"]} #{machine_settings["deployment_dbs_path"]} #{config.ssh.username} #{machine_settings["hostname"]} #{machine_settings["hostname"]}.local #{machine_settings["basics"]} #{machine_settings["lamp"]} #{machine_settings["geoip"]} #{machine_settings["iptables"]} #{machine_settings["fail2ban"]}"
      end

    end # config.vm.define

  end # machines.each

end
