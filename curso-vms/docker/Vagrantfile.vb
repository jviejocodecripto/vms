# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.provider "virtualbox" do |hv|
    hv.cpus = "8"
    hv.name = "docker"
    hv.memory = 32000
  end

  config.vm.provider "hyperv" do |hv|
    hv.cpus = "8"
    
    hv.maxmemory = 32000
    hv.memory = 16000
    hv.enable_enhanced_session_mode = true
  end


  config.vm.provision "shell", privileged: false, inline: <<-SHELL
      sudo apt update    
      sudo apt install -y docker.io
      sudo usermod -aG docker vagrant
      sudo newgrp docker 
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
      sudo chmod +x ./kind
      sudo mv ./kind /bin/kind
      sudo kind create cluster
      sudo apt-get install -y nfs-common
  SHELL

 
end
