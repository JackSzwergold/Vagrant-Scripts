Vagrant.configure(2) do |config|

  config.ssh.username = "vagrant"
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.hostname = "vagrant"

  # Shell script to provision the server.
  config.vm.provision "shell", inline: <<-SHELL

    # Setting the 'DEBIAN_FRONTEND' to a non-interactive mode.
    export DEBIAN_FRONTEND=noninteractive

    # Create the 'www-readwrite' group.
    sudo groupadd -f www-readwrite

    # Set the Vagrant user’s main group to be the 'www-readwrite' group.
    sudo usermod -g www-readwrite vagrant

    # Sync with the time/date server.
    sudo ntpdate ntp.ubuntu.com
    
    # Set the time zone data.
    # debconf-set-selections <<< "tzdata tzdata/Areas select America"
    # debconf-set-selections <<< "tzdata tzdata/Zones/America select New_York"
    # sudo dpkg-reconfigure tzdata
    echo "America/New_York" > /etc/timezone 
    dpkg-reconfigure -f noninteractive tzdata

    # Install 'sysstat'.
    sudo aptitude install -q -y sysstat

    # Enable 'sysstat'.
    sudo sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat

    # Add the user to the 'www-readwrite' group:
    sudo adduser vagrant www-readwrite

    # Install Avahi daemon stuff.
    sudo aptitude install -q -y avahi-daemon avahi-utils

    # Install generic tools.
    sudo aptitude install -q -y \
	  dnsutils traceroute nmap bc htop finger curl whois rsync lsof \
	  iftop figlet lynx mtr-tiny iperf nload zip unzip attr sshpass \
	  dkms mc elinks ntp dos2unix p7zip-full nfs-common imagemagick \
	  slurm sharutils uuid-runtime chkconfig quota pv trickle apachetop

    # Install and update the locate database.
	sudo aptitude install -q -y locate
	sudo updatedb

    # Install the core compiler and built options.
    sudo aptitude install -q -y build-essential

    # Install Git via PPA.
    sudo aptitude install -q -y python-software-properties
    sudo add-apt-repository -y ppa:git-core/ppa
    sudo aptitude update -q -y
    sudo aptitude upgrade -q -y
    sudo aptitude install -q -y subversion git git-core git-svn

    # Install postfix and general mail stuff.
    debconf-set-selections <<< "postfix postfix/mailname string vagrant.local"
    debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
    sudo aptitude install -q -y postfix mailutils

    # Set the server login banner with figlet.
    figlet Vagrant > /etc/motd

    # Set the default UMASK value in 'login.defs' to be 002 instead of 022.
    sudo sed -i 's/UMASK[ \t]*022/UMASK\t\t002/g' /etc/login.defs

    # Set the default UMASK value in 'common-session' to be 002 instead of 022.
    sudo sed -i 's/session optional[ \t]*pam_umask\.so/session\soptional\t\tpam_umask\.so\t\tumask=0002/g' /etc/pam.d/common-session

    # Fix for slow SSH client connections.
    sudo echo "\tPreferredAuthentications publickey,password,gssapi-with-mic,hostbased,keyboard-interactive" >> /etc/ssh/ssh_config

    # Install IPTables and IPSet stuff.
    debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
    debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
    sudo aptitude install -q -y iptables iptables-persistent ipset

  SHELL
end
