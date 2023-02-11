Vagrant.configure("2") do |cf|
      # NFS Server
      cf.vm.box = "bionic64"
      cf.vm.provider "virtualbox"
      cf.vm.network "private_network", ip: "192.168.56.4"
      cf.vm.provider "hyperv" do |hv|
        hv.cpus = "2"
        hv.vmname = "nfs"
        hv.maxmemory = 4096
        hv.memory = 4096
      end
      cf.vm.provider "virtualbox" do |vb|
        vb.name = "nfs"
        vb.cpus = "2"
        vb.memory = 4096
      end
      
      cf.vm.define "nfs-server" do |nfs|
        cf.vm.box = "generic/ubuntu2004"
        cf.vm.provision "shell",path: "bootstrap_nfs.sh"
      end
   
  end