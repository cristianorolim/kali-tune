#!/bin/bash

CONFIG_DIR=/var/kali-tune
APT_COMMAND=/usr/bin/apt-get
DOWN_COMMAND="axel -a -n 8"

install_aptfast()
{
    local APTFAST
    APTFAST=/usr/local/bin/apt-fast
    if [ -f $CONFIG_DIR/aptfast ];
    then
        echo "apt-fast already installed"
        APT_COMMAND=/usr/local/bin/apt-fast
    else
        echo "installing apt-fast"

        curl http://www.mattparnell.com/linux/apt-fast/apt-fast.sh > /tmp/apt-fast.tmp
        sed 's/axel -a/axel -a -n 8/' /tmp/apt-fast.tmp > /tmp/apt-fast
        rm /tmp/apt-fast.tmp
        mv /tmp/apt-fast /usr/local/bin
        chmod +x /usr/local/bin/apt-fast
        APT_COMMAND=/usr/local/bin/apt-fast
        
        touch $CONFIG_DIR/aptfast
    fi

    return 0
}

update_upgrade()
{
    $APT_COMMAND update
    $APT_COMMAND -y dist-upgrade

    return 0
}

regenerate_ssh()
{
    

    if [ -f $CONFIG_DIR/regenerate_ssh ];
    then
        echo "ssh keys were already regenerated"
    else
        echo "regenerating ssh keys"

        /bin/rm -fv /etc/ssh/ssh_host_*
        ssh-keygen -q -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
        ssh-keygen -q -f /etc/ssh/ssh_host_rsa_key -N '' -b 4096 -t rsa
        ssh-keygen -q -f /etc/ssh/ssh_host_ecdsa_key -N '' -b 521 -t ecdsa
        
        touch $CONFIG_DIR/regenerate_ssh
    fi

    return 0
}

install_extra_packages()
{
    $APT_COMMAND install -y iotop htop strace terminator rar unace apt-file filezilla gdebi tree
}

install_arachni()
{
    if [ -f $CONFIG_DIR/install_arachni ];
    then
        echo "arachni was already installed"
    else
        echo "installing arachni"

        wget http://downloads.arachni-scanner.com/arachni-1.1-0.5.7-linux-x86_64.tar.gz
        tar -zxvf arachni-1.1-0.5.7-linux-x86_64.tar.gz 
        mv arachni-1.1-0.5.7 /opt/
        for f in $(ls /opt/arachni-1.1-0.5.7/bin/); do ln -s /opt/arachni-1.1-0.5.7/bin/$f /usr/bin/$f; done
        rm -f arachni-1.1-0.5.7-linux-x86_64.tar.gz
        
        touch $CONFIG_DIR/install_arachni
    fi

    return 0
}

install_chrome()
{
    if [ -f $CONFIG_DIR/install_chrome ];
    then
        echo "chrome was already installed"
    else
        echo "installing chrome"

        $APT_COMMAND install -y libappindicator1
        wget  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        dpkg -i google-chrome-stable_current_amd64.deb
        rm -f google-chrome-stable_current_amd64.deb
        
        touch $CONFIG_DIR/install_chrome
    fi

    return 0
}

install_chromium()
{
    if [ -f $CONFIG_DIR/install_chromium ];
    then
        echo "chromium was already installed"
    else
        echo "installing chromium"

        $APT_COMMAND install -y chromium
        cp /etc/chromium/default /etc/chromium/default.orig
        sed 's/--password-store=detect/--user-data-dir --password-store=detect/' /etc/chromium/default > /tmp/default.tmp
        cat /tmp/default.tmp > /etc/chromium/default
        rm /tmp/default.tmp
        
        touch $CONFIG_DIR/install_chromium
    fi

    return 0
}

install_pev()
{
    if [ -f $CONFIG_DIR/install_pev ];
    then
        echo "pev was already installed"
    else
        echo "installing pev"

        wget http://sourceforge.net/projects/pev/files/pev-0.70/pev-0.70_amd64.deb/download -O pev-0.70_amd64.deb
        dpkg -i pev-0.70_amd64.deb
        rm -rf pev-0.70_amd64.deb
        
        touch $CONFIG_DIR/install_pev
    fi

    return 0
}

install_bashacks()
{
    if [ -f $CONFIG_DIR/install_bashacks ];
    then
        echo "bashacks was already installed"
    else
        echo "installing bashacks"

        git clone https://github.com/merces/bashacks.git
        cd bashacks
        make
        mkdir /opt/bashacks
        mv bashacks.sh /opt/bashacks/
        echo "source /opt/bashacks/bashacks.sh" >> $HOME/.bashrc
        source /opt/bashacks/bashacks.sh
        cd ./man/en
        gzip bashacks.1
        cp bashacks.1.gz /usr/man/man1/
        mandb
        cd ../../..
        rm -rf bashacks
        bashacks_depinstall
        
        touch $CONFIG_DIR/install_bashacks
    fi

    return 0
}

install_java_oracle()
{
    if [ -f $CONFIG_DIR/install_java_oracle ];
    then
        echo "java_oracle was already installed"
    else
        echo "installing java_oracle"

        wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz
        tar -zxvf jdk-8u45-linux-x64.tar.gz
        rm -f jdk-8u45-linux-x64.tar.gz
        mv jdk1.8.0_45/ /opt/

        update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_45/bin/java 1
        update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_45/bin/javac 1
        update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /opt/jdk1.8.0_45/jre/lib/amd64/libnpjp2.so 1
        update-alternatives --set java /opt/jdk1.8.0_45/bin/java
        update-alternatives --set javac /opt/jdk1.8.0_45/bin/javac
        update-alternatives --set mozilla-javaplugin.so /opt/jdk1.8.0_45/jre/lib/amd64/libnpjp2.so
        
        touch $CONFIG_DIR/install_java_oracle
    fi

    return 0
}

install_kernel_headers()
{
    $APT_COMMAND install -y linux-headers-$(uname -r)
}

enable_net_manager()
{
    if [ -f $CONFIG_DIR/enable_net_manager ];
    then
        echo "net_manager was already enabled"
    else
        echo "enabling net_manager"

        sed 's/managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf > /tmp/net.tmp
        cat /tmp/net.tmp > /etc/NetworkManager/NetworkManager.conf 
        rm -f /tmp/net.tmp
        service network-manager restart
        
        touch $CONFIG_DIR/enable_net_manager
    fi

    return 0
}

install_windows_theme()
{
    if [ -f $CONFIG_DIR/install_windows_theme ];
    then
        echo "windows_theme was already installed"
    else
        echo "installing windows_theme"

        wget https://launchpad.net/~upubuntu-com/+archive/ubuntu/gtk3/+files/win2-7_0.1_all.deb
        gdebi win2-7_0.1_all.deb
        rm -rf win2-7_0.1_all.deb
        gsettings set org.gnome.desktop.interface gtk-theme 'Win2-7-theme'
        gsettings set org.gnome.desktop.wm.preferences theme 'Win2-7-theme'
        gsettings set org.gnome.desktop.interface icon-theme 'Win2-7-icons'
        
        touch $CONFIG_DIR/install_windows_theme
    fi

    return 0
}

install_windows_background()
{
    if [ -f $CONFIG_DIR/install_windows_background ];
    then
        echo "windows_background was already installed"
    else
        echo "installing windows_background"

        wget http://static.wallpedes.com/wallpaper/charming/charming-wallpaper-for-windows-windows-wallpaper-hd-themes-location-7-xp-changer-live-8-free-download.jpg -O win-wall.jpg
        mv win-wall.jpg /usr/share/backgrounds/
        gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/win-wall.jpg

        wget http://p1.pichost.me/i/14/1366427.png -O win-bkgd.png
        mv win-bkgd.png /usr/share/images/desktop-base/
        sed 's/login-background.png/win-bkgd.png/' /usr/share/gdm/dconf/10-desktop-base-settings > /tmp/dsktop-set.tmp
        cat /tmp/dsktop-set.tmp > /usr/share/gdm/dconf/10-desktop-base-settings
        rm -f /tmp/dsktop-set.tmp
        
        touch $CONFIG_DIR/install_windows_background
    fi

    return 0
}

start()
{
    if [ -d $CONFIG_DIR ];
    then
        echo "config folder exists"
    else
        echo "config folder doesn't exist"
        echo "creating config folder"
        echo "mkdir $CONFIG_DIR" 
        mkdir $CONFIG_DIR
    fi

    return 0
}

start
install_aptfast
update_upgrade
regenerate_ssh
exit 0
install_extra_packages
install_arachni
install_chromium
install_pev
install_bashacks
install_java_oracle
install_kernel_headers
enable_net_manager
install_windows_theme
install_windows_background
exit 0

