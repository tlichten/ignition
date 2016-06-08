# -*- mode: ruby -*-
# vi: set ft=ruby :
require "yaml"

ENV['VAGRANT_NO_PARALLEL'] = 'yes'
CONF = YAML.load_file("env.yaml")

Vagrant.configure("2") do |config|
  config.vm.define :fuelmaster do |fuelmaster|
    fuelmaster.vm.box = "fuelmaster"
    fuelmaster.vm.box_url = "file://lib/package.box"
    fuelmaster.vm.boot_timeout = 7200
    fuelmaster.ssh.host = CONF["node"]["master"]["ip"]["admin"]
    fuelmaster.ssh.username = CONF["node"]["master"]["username"]
    fuelmaster.ssh.password = CONF["node"]["master"]["password"]
    fuelmaster.ssh.sudo_command = "%c"
    fuelmaster.ssh.insert_key = false
    fuelmaster.vm.synced_folder ".", "/vagrant", disabled: true
    fuelmaster.vm.network :private_network, :ip => "172.16.0.40"
    fuelmaster.vm.provision "shell", path: "fuel.sh"
    fuelmaster.vm.provision "file", source: "lib/parse_yaml.sh", destination: "parse_yaml.sh"
    fuelmaster.vm.provision "file", source: "env.yaml", destination: "env.yaml"
    fuelmaster.vm.provision "file", source: "fuel_deploy.sh", destination: "fuel_deploy.sh"
    fuelmaster.vm.provider :libvirt do |domain|
      domain.management_network_address = CONF["node"]["master"]["cidr"]["admin"]
      domain.memory = CONF["node"]["master"]["memory"]
      domain.cpus = CONF["node"]["master"]["cpu"]
      domain.nested = true
      domain.volume_cache = 'none'
      domain.storage :file, :device => :cdrom, :path => CONF["env"]["iso"]
      domain.boot 'hd'
      domain.boot 'cdrom'
    end
  end

  CONF["node"]["slaves"].each_with_index do |slave,i|
    config.vm.define vm_name = "fuelslave-%02d" % i do |fuelslave|  
      fuelslave.vm.network :private_network, :ip => "172.16.0.4#{2+i}"
      
      fuelslave.vm.provider :libvirt do |domain|
        domain.management_network_address = CONF["node"]["master"]["cidr"]["admin"]
        domain.management_network_mac = "DEADAC1D00%02d" % i
        domain.memory = slave["memory"]
        domain.cpus = slave["cpu"]
        domain.graphics_port = 5901+i
        domain.storage :file, :size => slave["disk"], :type => 'raw'
        domain.boot 'network'
        domain.boot 'hd'
      end
    end
  end

  config.trigger.after :up, :vm => "fuelmaster" do
    CONF["node"]["slaves"].each_with_index do |slave,i|
      run "vagrant up --provider libvirt fuelslave-%02d" % i
    end
    run_remote "bash fuel_deploy.sh"
  end

end
