#!/usr/bin/env bash -ex

yum -y install wget gcc libxslt-devel libxml2-devel libvirt-devel libguestfs-tools-c ruby-devel ruby qemu-kvm libvirt virt-install bridge-utils rsync

sudo rmmod kvm-intel

sudo sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/dist.conf"

sudo modprobe kvm-intel

yum -y install https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm

vagrant plugin install vagrant-libvirt

cat <<EOF > Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.define :fuelmaster do |fuelmaster|
    fuelmaster.vm.box = "centos/7"
    fuelmaster.ssh.insert_key = false
    fuelmaster.vm.synced_folder ".", "/vagrant", disabled: true

    fuelmaster.vm.provider :libvirt do |domain|
      domain.memory = 2048
      domain.cpus = 2
      domain.nested = true
      domain.volume_cache = 'none'
      domain.storage :file, :device => :cdrom, :path => '/tmp/MirantisOpenStack-8.0.iso'
      domain.boot 'cdrom'
      domain.storage :file, :size => '100G'
    end

  end
end
EOF

wget http://9f2b43d3ab92f886c3f0-e8d43ffad23ec549234584e5c62a6e24.r60.cf1.rackcdn.com/MirantisOpenStack-8.0.iso -O /tmp/MirantisOpenStack-8.0.iso
chmod 777 /tmp/MirantisOpenStack-8.0.iso
systemctl start libvirtd
systemctl enable libvirtd
vagrant up --provider libvirt

