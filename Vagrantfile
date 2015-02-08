# -*- mode: ruby -*-
# vi: set ft=ruby :

# network => ip
networks = {
  'management' => '10.0.0.',
  'inst_tun' => '10.0.1.',
  'external' => '172.16.0.',
}

# node => offset
nodes = {
  'controller' => {
    'n' => 1,
    'offset' => 10,
    'memory' => 1500,
    'cpus' => 1,
  },
  'network' => {
    'n' => 1,
    'offset' => 20,
    'memory' => 512,
    'cpus' => 1,
  },
  'compute' => {
    'n' => 1,
    'offset' => 30,
    'memory' => 1024,
    'cpus' => 1,
  },
}

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"

  nodes.each do |node_name, node|
    node['n'].times do |i|
      ips = {}
      networks.each do |network, ip|
        ips[network] = "%s%d" % [ip, (node['offset']+i+1)]
      end
      
      puts "creating... #{node_name} with #{ips['management']} #{ips['inst_tun']} #{ips['external']}"
      config.vm.define "#{node_name}" do |box|
        box.vm.hostname = "#{node_name}"
        box.vm.network :private_network, ip: "#{ips['management']}", :netmask => "255.255.255.0"
        box.vm.network :private_network, ip: "#{ips['inst_tun']}", :netmask => "255.255.255.0"
        box.vm.network :private_network, ip: "#{ips['external']}", :netmask => "255.255.255.0"
        config.vm.provider :virtualbox do |vbox|
          vbox.customize ["modifyvm", :id, "--memory", node['memory']]
          vbox.customize ["modifyvm", :id, "--cpus", node['cpus']]
        end
      end
    end
  end
end