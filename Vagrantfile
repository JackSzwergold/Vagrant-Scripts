Vagrant.configure(2) do |config|

  config.ssh.username = "vagrant"
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.hostname = "vagrant"

  # Shell script to provision the server.
  config.vm.provision "shell", inline: <<-SHELL

    # Create the 'www-readwrite' group.
    sudo groupadd www-readwrite

    # Set the Vagrant user’s main group to be the 'www-readwrite' group.
    sudo usermod -g www-readwrite vagrant

    # Add the user to the 'www-readwrite' group:
    sudo adduser vagrant www-readwrite

    # Install Avahi daemon stuff.
    sudo aptitude install -y avahi-daemon avahi-utils

    # Install generic tools.
    sudo aptitude install -y \
	  dnsutils traceroute nmap bc htop finger curl whois rsync lsof \
	  iftop figlet lynx mtr-tiny iperf nload zip unzip attr sshpass \
	  dkms mc elinks ntp dos2unix p7zip-full nfs-common imagemagick \
	  slurm sharutils uuid-runtime chkconfig quota pv trickle apachetop

    # Install and update the locate database.
	sudo aptitude install -y locate
	sudo updatedb

    # Install the core compiler and built options.
    sudo aptitude install -y build-essential

    # Install Git via PPA.
    sudo aptitude install -y python-software-properties
    sudo add-apt-repository ppa:git-core/ppa
    sudo aptitude update
    sudo aptitude upgrade
    sudo aptitude install -y subversion git git-core git-svn

    # Install postfix and general mail stuff.
    debconf-set-selections <<< "postfix postfix/mailname string vagrant.local"
    debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
    sudo aptitude install -y postfix mailutils

    # Set the server login banner with figlet.
    figlet Vagrant > /etc/motd

  SHELL
end
