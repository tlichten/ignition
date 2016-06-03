# -*- mode: ruby -*-
# vi: set ft=ruby :
require "yaml"

CONF = YAML.load_file("fuel_client.yaml")
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|
  config.vm.define :fuelmaster do |fuelmaster|
    fuelmaster.vm.box = "fuelmaster"
    fuelmaster.vm.box_url = "file://package.box"
    fuelmaster.vm.boot_timeout = 7200
    fuelmaster.ssh.host = CONF["node"]["master"]["ip"]["admin"]
    fuelmaster.ssh.username = CONF["node"]["master"]["username"]
    fuelmaster.ssh.password = CONF["node"]["master"]["password"]
    fuelmaster.ssh.sudo_command = "%c"
    fuelmaster.ssh.insert_key = false
    fuelmaster.vm.synced_folder ".", "/vagrant", disabled: true
    fuelmaster.vm.network :private_network, :ip => "172.16.0.40"
    fuelmaster.vm.network "forwarded_port", guest: 8000, host: 8000, gateway_ports: true, host_ip: '*'
    fuelmaster.vm.provision "shell", path: "fuel.sh"
    fuelmaster.vm.provider :libvirt do |domain|
      domain.management_network_address = '10.20.0.0/24'
      domain.memory = 6048
      domain.cpus = 4
      domain.nested = true
      domain.volume_cache = 'none'
      domain.storage :file, :device => :cdrom, :path => '/tmp/MirantisOpenStack-8.0.iso'
      domain.boot 'hd'
      domain.boot 'cdrom'
    end
  end

  config.vm.define :pxeclient0 do |pxeclient|
    pxeclient.vm.network :private_network, :ip => "172.16.0.41"
    pxeclient.vm.network "forwarded_port", guest: 8080, host: 80, gateway_ports: true, host_ip: '*', guest_ip: '172.16.0.3'
    pxeclient.vm.provider :libvirt do |domain|
      domain.management_network_address = '10.20.0.0/24'
      domain.memory = 12000
      domain.cpus = 4
      domain.graphics_port = 5901
      domain.storage :file, :size => '100G', :type => 'raw'
      domain.boot 'network'
      domain.boot 'hd'
    end
  end

  config.vm.define :pxeclient1 do |pxeclient|
    pxeclient.vm.network :private_network, :ip => "172.16.0.42"
    pxeclient.vm.provider :libvirt do |domain|
      domain.management_network_address = '10.20.0.0/24'
      domain.memory = 48000
      domain.cpus = 32
      domain.graphics_port = 5902
      domain.storage :file, :size => '500G', :type => 'raw'
      domain.boot 'network'
      domain.boot 'hd'
    end
  end

  config.vm.define :pxeclient2 do |pxeclient|
    pxeclient.vm.network :private_network, :ip => "172.16.0.43"
    pxeclient.vm.provider :libvirt do |domain|
      domain.management_network_address = '10.20.0.0/24'
      domain.memory = 48000
      domain.cpus = 32
      domain.graphics_port = 5903
      domain.storage :file, :size => '500G', :type => 'raw'
      domain.boot 'network'
      domain.boot 'hd'
    end
  end
end
