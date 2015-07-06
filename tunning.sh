#!/bin/bash

APT_COMMAND=/usr/bin/apt-get
DOWN_COMMAND="axel -a -n 8"

install_aptfast()
{
    curl http://www.mattparnell.com/linux/apt-fast/apt-fast.sh > /tmp/apt-fast.tmp
    sed 's/axel -a/axel -a -n 8/' /tmp/apt-fast.tmp > /tmp/apt-fast
    rm /tmp/apt-fast.tmp
    mv /tmp/apt-fast /usr/local/bin
    chmod +x /usr/local/bin/apt-fast
    APT_COMMAND=/usr/local/bin/apt-fast
}

regenerate_ssh()
{
    /bin/rm -fv /etc/ssh/ssh_host_*
    ssh-keygen -q -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
    ssh-keygen -q -f /etc/ssh/ssh_host_rsa_key -N '' -b 4096 -t rsa
    ssh-keygen -q -f /etc/ssh/ssh_host_ecdsa_key -N '' -b 521 -t ecdsa
}

install_extra_packages()
{
    $APT_COMMAND install -y iotop htop strace terminator rar unace apt-file filezilla gdebi tree
}

install_arachni()
{
    wget http://downloads.arachni-scanner.com/arachni-1.1-0.5.7-linux-x86_64.tar.gz
    tar -zxvf arachni-1.1-0.5.7-linux-x86_64.tar.gz 
    mv arachni-1.1-0.5.7 /opt/
    for f in $(ls /opt/arachni-1.1-0.5.7/bin/); do ln -s /opt/arachni-1.1-0.5.7/bin/$f /usr/bin/$f; done
    rm -f arachni-1.1-0.5.7-linux-x86_64.tar.gz 
}

install_chrome()
{
    $APT_COMMAND install -y libappindicator1
    wget  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    dpkg -i google-chrome-stable_current_amd64.deb
}

install_chromium()
{
    $APT_COMMAND install -y chromium
    cp /etc/chromium/default /etc/chromium/default.orig
    sed 's/--password-store=detect/--user-data-dir --password-store=detect/' /etc/chromium/default > /tmp/default.tmp
    cat /tmp/default.tmp > /etc/chromium/default
    rm /tmp/default.tmp
}

install_pev()
{
    wget http://sourceforge.net/projects/pev/files/pev-0.70/pev-0.70_amd64.deb/download -O pev-0.70_amd64.deb
    dpkg -i pev-0.70_amd64.deb
    rm -rf pev-0.70_amd64.deb
}

install_extra_packages()
{
    $APT_COMMAND install -y iotop htop strace terminator rar unace apt-file filezilla gdebi tree
}

install_bash_hacks()
{
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
}

install_java_oracle()
{
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
}

install_kernel_headers()
{
    $APT_COMMAND install -y linux-headers-$(uname -r)
}

enable_net_manager()
{
    sed 's/managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf > /tmp/net.tmp
    cat /tmp/net.tmp > /etc/NetworkManager/NetworkManager.conf 
    rm -f /tmp/net.tmp
    service network-manager restart
}

#install_aptfast
#regenerate_ssh
#install_extra_packages
#install_arachni
#install_chromium
#install_pev
#install_bash_hacks
#install_java_oracle
#install_kernel_headers
enable_net_manager

