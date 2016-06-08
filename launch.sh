#!/usr/bin/env bash
set -o xtrace

yum -y install git wget gcc libxslt-devel libxml2-devel libvirt-devel libguestfs-tools-c ruby-devel ruby qemu-kvm libvirt virt-install bridge-utils rsync

rmmod kvm-intel
sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/dist.conf"

modprobe kvm-intel

rpm -qa | grep -qw vagrant || yum -y install https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm

vagrant plugin list | grep -qw vagrant-libvirt || vagrant plugin install vagrant-libvirt
vagrant plugin list | grep -qw vagrant-triggers || vagrant plugin install vagrant-triggers

wget -nc http://9f2b43d3ab92f886c3f0-e8d43ffad23ec549234584e5c62a6e24.r60.cf1.rackcdn.com/MirantisOpenStack-8.0.iso -O /tmp/MirantisOpenStack-8.0.iso
chmod 777 /tmp/MirantisOpenStack-8.0.iso
systemctl start libvirtd
systemctl enable libvirtd
virsh net-define lib/vagrant-libvirt.xml
virsh net-start vagrant-libvirt

vagrant up --provider libvirt

