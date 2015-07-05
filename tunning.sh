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

regenerate_ssh()
{
    /bin/rm -fv /etc/ssh/ssh_host_*
    ssh-keygen -q -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
    ssh-keygen -q -f /etc/ssh/ssh_host_rsa_key -N '' -b 4096 -t rsa
    ssh-keygen -q -f /etc/ssh/ssh_host_ecdsa_key -N '' -b 521 -t ecdsa
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

regenerate_ssh
install_aptfast
install_chromium
install_extra_packages
install_pev

