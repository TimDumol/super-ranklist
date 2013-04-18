#-*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  module_path = ["puppet/modules", "puppet/vendor_modules"]

  config.vm.box = "ubuntu-precise-32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  config.vm.share_folder "ranklist", "/home/vagrant/ranklist", '.'
  config.vm.share_folder "frontend", "/srv/ranklist", "build/frontend"
  config.vm.network :hostonly, "172.16.0.41"
  config.vm.forward_port 3000, 3000
  config.vm.forward_port 8080, 8080
  config.vm.forward_port 28015, 28015
  config.vm.forward_port 29015, 29015
  config.vm.provision :puppet, :module_path => module_path do |puppet|
    puppet.manifests_path = "puppet"
    puppet.manifest_file  = "angular-momentum.pp"
  end
  config.vm.host_name = "angular-momentum"
end
