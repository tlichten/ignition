#!/usr/bin/env bash
set -o xtrace

. lib/parse_yaml.sh

eval $(parse_yaml env.yaml)
eval $(parse_yaml ./examples/$env_example/env.yaml)

yum -y install git wget gcc libxslt-devel libxml2-devel libvirt-devel libguestfs-tools-c ruby-devel ruby qemu-kvm libvirt virt-install bridge-utils rsync

rmmod kvm-intel
sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/dist.conf"

modprobe kvm-intel

rpm -qa | grep -qw vagrant || yum -y install https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm

vagrant plugin list | grep -qw vagrant-libvirt || vagrant plugin install vagrant-libvirt
vagrant plugin list | grep -qw vagrant-triggers || vagrant plugin install vagrant-triggers

wget -nc $env_iso -O /tmp/Mirantis.iso
chmod 777 /tmp/Mirantis.iso
systemctl start libvirtd
systemctl enable libvirtd
virsh net-define lib/vagrant-libvirt.xml
virsh net-start vagrant-libvirt

echo "Exposing installation on public interface"
MYIP=$(curl -s 4.ifcfg.me)
iptables -I FORWARD -m state -d 10.20.0.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -I PREROUTING -p tcp -d $MYIP --dport 8443 -j DNAT --to-destination 10.20.0.2:8443
iptables -I FORWARD -m state -d 172.16.0.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
for i in {80,443,5000,6080,8000,8004,8080,8082,8386,8773,8774,8776,8777,9292,9696}; do iptables -t nat -I PREROUTING -p tcp -d $MYIP --dport $i -j DNAT --to-destination 172.16.0.3:$i; done


vagrant up --provider libvirt

