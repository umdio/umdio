 # -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|  
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder ".", "/home/vagrant/umdio"
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash -l'"
  config.vm.provision :shell, path: "bootstrap.sh", privileged: false
  config.vm.network :forwarded_port, guest: 80, host: 4080, auto_correct: true
  config.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
  config.vm.network :forwarded_port, guest: 4000, host: 4000, auto_correct: true
end
