# -*- mode: ruby -*-
# vi: set ft=ruby :

# set appropriate env variables if you want to deploy to digitalocean instead of virtualbox (i.e. production)
# if you want to do this, remember to install the vagrant_digitalocean plugin
if ENV['VAGRANT_TARGET'] && ENV['VAGRANT_TARGET'] == 'digitalocean' then
  Vagrant.configure(2) do |config|
    config.vm.box = "digital_ocean"
    config.ssh.private_key_path = "~/.ssh/id_rsa"
    config.vm.provider :digital_ocean do |provider|
      provider.client_id = ENV['DO_CLIENT_ID']
      provider.api_key = ENV['DO_API_KEY']
      provider.image = "Ubuntu 14.04 x64"
      provider.region = "New York 2"
    end
    config.vm.synced_folder ".", "~/umdio"
  end
else
  Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.synced_folder ".", "/home/vagrant/umdio"
  end
end

Vagrant.configure(2) do |config|
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash -l'" 
  config.vm.provision :shell, path: "bootstrap.sh", privileged: false
  config.vm.network :forwarded_port, guest: 80, host: 4080, auto_correct: true
  config.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
  config.vm.network :forwarded_port, guest: 4000, host: 4000, auto_correct: true
end