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
        return 0
    fi

    echo "installing apt-fast"

    curl http://www.mattparnell.com/linux/apt-fast/apt-fast.sh > /tmp/apt-fast.tmp
    sed 's/axel -a/axel -a -n 8/' /tmp/apt-fast.tmp > /tmp/apt-fast
    rm /tmp/apt-fast.tmp
    mv /tmp/apt-fast /usr/local/bin
    chmod +x /usr/local/bin/apt-fast
    APT_COMMAND=/usr/local/bin/apt-fast

    touch $CONFIG_DIR/aptfast
    
    return 0
}

update_upgrade()
{
    echo "executing update_upgrade"

    $APT_COMMAND update
    $APT_COMMAND -y dist-upgrade
        
    return 0
}

redo_sources_list()
{
    if [ -f $CONFIG_DIR/redo_sources_list ];
    then
        echo "sources.list was already regenerated"
        return 0
    fi

    echo "regenerating sources.list"

    echo "deb http://http.kali.org/kali moto main non-free contrib" > /etc/apt/sources.list
    echo "deb-src http://http.kali.org/kali moto main non-free contrib" >> /etc/apt/sources.list
    echo "deb http://security.kali.org/ moto/updates main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://security.kali.org/ moto/updates main contrib non-free" >> /etc/apt/sources.list

    touch $CONFIG_DIR/redo_sources_list

    return 0
}

regenerate_ssh()
{
    if [ -f $CONFIG_DIR/regenerate_ssh ];
    then
        echo "ssh keys were already regenerated"
        return 0
    fi

    echo "regenerating ssh keys"

    /bin/rm -fv /etc/ssh/ssh_host_*
    ssh-keygen -q -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
    ssh-keygen -q -f /etc/ssh/ssh_host_rsa_key -N '' -b 4096 -t rsa
    ssh-keygen -q -f /etc/ssh/ssh_host_ecdsa_key -N '' -b 521 -t ecdsa
        
    touch $CONFIG_DIR/regenerate_ssh

    return 0
}

install_extra_packages()
{
    $APT_COMMAND install -y iotop htop strace terminator rar unace apt-file filezilla gdebi tree secure-delete
}

install_arachni()
{
    local ARACH_FILE
    ARACH_FILE=arachni-1.1-0.5.7-linux-x86_64.tar.gz
    if [ -f $CONFIG_DIR/install_arachni ];
    then
        echo "arachni was already installed"
        return 0
    fi

    echo "installing arachni"

    if [ -f $CONFIG_DIR/$ARACH_FILE ];
    then
        echo "$ARACH_FILE was already downloaded"
    else
        wget http://downloads.arachni-scanner.com/$ARACH_FILE -O $CONFIG_DIR/$ARACH_FILE
    fi

    echo "checking SHA512..."
    cd $CONFIG_DIR
    if echo "7cb672b788e57a2a9cea5e218f7473628ad813a87f24a890a1e116b88aad404b01f1d739f23700fd782835416310112718e9693924c81c0d5066e6c08b74eeb2  $CONFIG_DIR/$ARACH_FILE" | sha512sum --status -c - ;
    then
        echo "passed"
    else
        echo "not passed, aborting"
        return 1
    fi
    
    tar -zxvf arachni-1.1-0.5.7-linux-x86_64.tar.gz 
    mv arachni-1.1-0.5.7 /opt/
    for f in $(ls /opt/arachni-1.1-0.5.7/bin/); do ln -s /opt/arachni-1.1-0.5.7/bin/$f /usr/bin/$f; done
    #rm -f arachni-1.1-0.5.7-linux-x86_64.tar.gz
        
    touch $CONFIG_DIR/install_arachni

    return 0
}

install_chrome()
{
    if [ -f $CONFIG_DIR/install_chrome ];
    then
        echo "chrome was already installed"
        return 0
    fi

    echo "installing chrome"

    $APT_COMMAND install -y libappindicator1
    wget  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    dpkg -i google-chrome-stable_current_amd64.deb
    rm -f google-chrome-stable_current_amd64.deb
    
    touch $CONFIG_DIR/install_chrome

    return 0
}

install_chromium()
{
    if [ -f $CONFIG_DIR/install_chromium ];
    then
        echo "chromium was already installed"
        return 0
    fi

    echo "installing chromium"

    $APT_COMMAND install -y chromium
    cp /etc/chromium/default /etc/chromium/default.orig
    sed 's/--password-store=detect/--user-data-dir --password-store=detect/' /etc/chromium/default > /tmp/default.tmp
    cat /tmp/default.tmp > /etc/chromium/default
    rm /tmp/default.tmp
    
    touch $CONFIG_DIR/install_chromium

    return 0
}

install_pev()
{
    if [ -f $CONFIG_DIR/install_pev ];
    then
        echo "pev was already installed"
        return 0
    fi

    echo "installing pev"

    wget http://sourceforge.net/projects/pev/files/pev-0.70/pev-0.70_amd64.deb/download -O pev-0.70_amd64.deb
    dpkg -i pev-0.70_amd64.deb
    rm -rf pev-0.70_amd64.deb
    
    touch $CONFIG_DIR/install_pev

    return 0
}

install_bashacks()
{
    if [ -f $CONFIG_DIR/install_bashacks ];
    then
        echo "bashacks was already installed"
        return 0
    fi

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

    return 0
}

install_java_oracle()
{
    if [ -f $CONFIG_DIR/install_java_oracle ];
    then
        echo "java_oracle was already installed"
        return 0
    fi

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
        return 0
    fi

    echo "enabling net_manager"

    sed 's/managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf > /tmp/net.tmp
    cat /tmp/net.tmp > /etc/NetworkManager/NetworkManager.conf 
    rm -f /tmp/net.tmp
    service network-manager restart
    
    touch $CONFIG_DIR/enable_net_manager

    return 0
}

install_windows_theme()
{
    if [ -f $CONFIG_DIR/install_windows_theme ];
    then
        echo "windows_theme was already installed"
        return 0
    fi

    echo "installing windows_theme"

    wget https://launchpad.net/~upubuntu-com/+archive/ubuntu/gtk3/+files/win2-7_0.1_all.deb

    $APT_COMMAND -y install gtk2-engines-aurora gtk2-engines-murrine gtk2-engines-pixbuf gtk3-engines-unico murrine-themes
    dpkg -i win2-7_0.1_all.deb
    rm -rf win2-7_0.1_all.deb
    gsettings set org.gnome.desktop.interface gtk-theme 'Win2-7-theme'
    gsettings set org.gnome.desktop.wm.preferences theme 'Win2-7-theme'
    gsettings set org.gnome.desktop.interface icon-theme 'Win2-7-icons'
    
    touch $CONFIG_DIR/install_windows_theme

    return 0
}

install_windows_background()
{
    if [ -f $CONFIG_DIR/install_windows_background ];
    then
        echo "windows_background was already installed"
        return 0
    fi

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

    return 0
}

change_kali_menu()
{
    local KMFILE
    KMFILE="/usr/share/desktop-directories/Kali.directory"
    if [ -f $CONFIG_DIR/change_kali_menu ];
    then
        echo "kali menu was already changed"
        return 0
    fi

    echo "changing kali menu"

    sed 's/Kali Linux/Aid Tools/' $KMFILE | sed 's/k.png/system-services-trans.pnp/' > /tmp/kmenu.tmp
    cat /tmp/kmenu.tmp > $KMFILE
    rm /tmp/kmenu.tmp

    touch $CONFIG_DIR/change_kali_menu

    return 0
}

change_kernel_hard()
{
    local CONF
    if [ -f $CONFIG_DIR/change_kernel_hard ];
    then
        echo "kernel parameters were already changed"
        return 0
    fi

    echo "changing kernel parameters"

    CONF=/etc/sysctl.d/60-extra-hardening.conf
    echo "net.ipv4.tcp_fin_timeout=30" >> $CONF
    sysctl -w net.ipv4.tcp_fin_timeout=30

    echo "net.ipv4.ip_local_port_range = 1025 65535" >> $CONF
    sysctl -w net.ipv4.ip_local_port_range="1025 65535"

    echo "net.ipv4.tcp_timestamps=0" >> $CONF
    sysctl -w net.ipv4.tcp_timestamps=0

    echo "net.ipv4.ip_default_ttl=128" >> $CONF
    sysctl -w net.ipv4.ip_default_ttl=128

    touch $CONFIG_DIR/change_kernel_hard

    return 0
}

start_tune()
{
    if [ -d $CONFIG_DIR ];
    then
        echo "config folder exists"
        return 0
    fi

    echo "config folder doesn't exist"
    echo "creating config folder"
    echo "mkdir $CONFIG_DIR" 
    mkdir $CONFIG_DIR

    return 0
}

clean()
{
    echo "cleaning"
    apt-get autoremove -y
    apt-get clean
}

install_vmware_tools()
{
    if [ -f $CONFIG_DIR/install_vmware_tools ];
    then
        echo "vmware_tools already installed"
        return 0
    fi

    local VMT_FILE
    VMT_FILE="com.vmware.fusion.tools.linux.zip.tar"
    if [ -f $CONFIG_DIR/$VMT_FILE ];
    then
        echo "$CONFIG_DIR/$VMT_FILE exists"
    else
        echo "downloading $VMT_FILE"
        axel -n 8 -a https://softwareupdate.vmware.com/cds/vmw-desktop/fusion/7.1.2/2779224/packages/$VMT_FILE -o $CONFIG_DIR/$VMT_FILE
    fi

    echo "checking SHA512..."
    cd $CONFIG_DIR
    if echo "9aa69d307afdd3aca92428afc8016b824a06657cfaa36a473cab1ad94d0669c4cd6972df79180d241da2ac04e2b263a8dcd796ed88bd5cd433a7d1af83feba05  $VMT_FILE" | sha512sum --status -c - ;
    then
        echo "passed"
    else
        echo "not passed, aborting"
        return 1
    fi
    tar -xvf $VMT_FILE
    unzip com.vmware.fusion.tools.linux.zip
    cd ./payload/
    7z x linux.iso
    tar -zxvf VMwareTools-9.9.3-2759765.tar.gz
    cd vmware-tools-distrib/
    ./vmware-install.pl -d
    cd ../..
    for f in ./payload com.vmware.fusion.tools.linux.zip descriptor.xml manifest.plist;
    do
        rm -rf $f;
    done

    touch $CONFIG_DIR/install_vmware_tools
    return 0
}

enable_vim_syntax_high()
{
    if [ -f $CONFIG_DIR/enable_vim_syntax_high ];
    then
        echo "vim syntax highlighting already enabled"
        return 0
    fi

    echo "enabling vim syntax highlighting"

    sed 's/"syntax on/syntax on/' /etc/vim/vimrc > /tmp/vimrc.tmp
    cat /tmp/vimrc.tmp > /etc/vim/vimrc
    rm -f /tmp/vimrc.tmp

    touch $CONFIG_DIR/enable_vim_syntax_high

    return 0
}

case $1 in
    "all")
        echo "all"
        start_tune
        redo_sources_list
        install_aptfast
        update_upgrade
        regenerate_ssh
        install_extra_packages
        install_arachni
        install_chromium
        install_pev
        install_bashacks
        install_java_oracle
        install_kernel_headers
        install_windows_theme
        install_windows_background
        enable_net_manager
        change_kali_menu
        change_kernel_hard
        enable_vim_syntax_high
        clean

        exit 0
    ;;
    "vmtools")
        echo "vmtools"
        install_aptfast
        install_kernel_headers
        install_vmware_tools
    ;;
    "update")
        echo "update"
        start_tune
        install_aptfast
        update_upgrade
        clean
    ;;
    "windownize")
        echo "windownize"
        start_tune
        install_aptfast
        install_windows_theme
        install_windows_background
        change_kali_menu
    ;;
    "vimsyntax")
        echo "vimsyntax"
        start_tune
        enable_vim_syntax_high
    ;;
    "java")
        echo "java"
        start_tune
        install_java_oracle
    ;;
    "arachni")
        echo "arachni"
        start_tune
        install_arachni
    ;;

	*) echo "Options:"
           echo "    all"
           echo "    vmtools"
           echo "    update"
           echo "    windownize"
           echo "    vimsyntax"
           echo "    java"
           echo "    arachni"
    ;;
esac

exit 0

