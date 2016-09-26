#!/usr/bin/env bash
set -o xtrace

. lib/parse_yaml.sh
eval $(parse_yaml ../env.yaml)

if [ -f /etc/lsb-release ]; then
  DISTRO="Ubuntu"
elif [ -f /etc/redhat-release ]; then
  DISTRO="CentOS"
else
  echo "Unable to determine if Ubuntu or CentOS"
  exit 1
fi

case $DISTRO in
    'Ubuntu')
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y language-pack-en locales-all
    export LANGUAGE=en_US.UTF-8; export LANG=en_US.UTF-8; export LC_ALL=en_US.UTF-8; locale-gen en_US.UTF-8
    apt-get install -y keyboard-configuration && dpkg-reconfigure keyboard-configuration && dpkg-reconfigure locales
    apt-get -y install libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev qemu-kvm libvirt-bin bridge-utils build-essential
    ;;
    'CentOS')
    yum -y update && yum -y install git wget gcc libxslt-devel libxml2-devel libvirt-devel libguestfs-tools-c ruby-devel ruby qemu-kvm libvirt virt-install bridge-utils rsync
    ;;
esac


rmmod kvm-intel

case $DISTRO in
    'Ubuntu')
    sh -c "echo 'options kvm-intel nested=1' > /etc/modprobe.d/qemu-system-x86.conf"
    ;;
    'CentOS')
    sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/dist.conf"
    ;;
esac

modprobe kvm-intel

case $DISTRO in
    'Ubuntu')
    curl -O https://releases.hashicorp.com/vagrant/1.8.5/vagrant_1.8.5_x86_64.deb
    dpkg -i vagrant*.deb
    ;;
    'CentOS')
    rpm -qa | grep -qw vagrant || yum -y install https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm
    ;;
esac

vagrant plugin list | grep -qw vagrant-libvirt || vagrant plugin install vagrant-libvirt
vagrant plugin list | grep -qw vagrant-triggers || vagrant plugin install vagrant-triggers

case $DISTRO in
    'Ubuntu')
    systemctl start libvirt-bin
    systemctl enable libvirt-bin
    systemctl start virtlogd
    systemctl enable virtlogd
    ;;
    'CentOS')
    systemctl start libvirtd
    systemctl enable libvirtd
    ;;
esac


virsh net-define lib/vagrant-libvirt.xml
virsh net-start vagrant-libvirt

curl -o /var/lib/libvirt/images/MirantisOpenStack.iso $env_iso
chmod 777 /var/lib/libvirt/images/MirantisOpenStack.iso

echo "Exposing installation on public interface"
MYIP=$(curl -s checkip.amazonaws.com)
iptables -I FORWARD -m state -d 10.20.0.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -I PREROUTING -p tcp -d $MYIP --dport 8443 -j DNAT --to-destination 10.20.0.2:8443
iptables -I FORWARD -m state -d 172.16.0.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
for i in {80,443,5000,6080,8000,8004,8080,8082,8386,8773,8774,8776,8777,9292,9696}; do iptables -t nat -I PREROUTING -p tcp -d $MYIP --dport $i -j DNAT --to-destination 172.16.0.3:$i; done
iptables -t nat -A POSTROUTING -j MASQUERADE -s  172.16.0.0/24 ! -d 172.16.0.0/24
iptables -t nat -A POSTROUTING -j MASQUERADE -s  10.20.0.0/24 ! -d 10.20.0.0/24

vagrant up &
pid=$!
sleep 60
export LANG=en_US.UTF-8
set +o xtrace
while [ -d /proc/$pid ] ; do
    virsh -q send-key provision_fuelmaster KEY_ENTER
    sleep 4
    virsh -q send-key provision_fuelmaster KEY_F8
done
set -o xtrace


echo "Exposing installation on public interface"
MYIP=$(curl -s checkip.amazonaws.com)
iptables -I FORWARD -m state -d 10.20.0.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -I PREROUTING -p tcp -d $MYIP --dport 8443 -j DNAT --to-destination 10.20.0.2:8443
iptables -I FORWARD -m state -d 172.16.0.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
for i in {80,443,5000,6080,8000,8004,8080,8082,8386,8773,8774,8776,8777,9292,9696}; do iptables -t nat -I PREROUTING -p tcp -d $MYIP --dport $i -j DNAT --to-destination 172.16.0.3:$i; done
iptables -t nat -A POSTROUTING -j MASQUERADE -s  172.16.0.0/24 ! -d 172.16.0.0/24
iptables -t nat -A POSTROUTING -j MASQUERADE -s  10.20.0.0/24 ! -d 10.20.0.0/24
