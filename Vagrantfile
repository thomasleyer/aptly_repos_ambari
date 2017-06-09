# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.define "aptly" do |aptly|
    aptly.vm.provision "shell", inline: "/vagrant/setup_aptly.sh"
    aptly.vm.hostname = "aptly"
    aptly.vm.network "private_network", ip: "192.168.100.2"
    aptly.vm.box = "ubuntu/trusty64"
  end
  config.vm.define "consumer" do |consumer|
    consumer.vm.box = "ubuntu/trusty64"
    consumer.vm.hostname = "consumer"
    consumer.vm.network "private_network", ip: "192.168.100.3"
  end
end
