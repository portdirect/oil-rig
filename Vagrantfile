# -*- mode: ruby -*-
# vi: set ft=ruby :

def construct_vm_data(base_ip_network, config)
  results = []
  (0...config[:count]).each do |i|
    results.push({
      ip: "%s%d" % [base_ip_network, config[:start_ip] + i],
      hostname: "%s%d" % [config[:name_prefix], i],
    })
  end

  results
end

Vagrant.configure("2") do |config|
  #
  # Useful Configuration
  #
  base_ip_network = "192.168.77."
  drill_master_config = {
    count: 3,
    name_prefix: "m",
    start_ip: 10,
  }

  drill_worker_config = {
    count: 4,
    name_prefix: "w",
    start_ip: 20,
  }

  #
  # Static Configuration
  #
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_check_update = false

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = "2048"
  end

  #
  # Provisioning
  #
  drill_masters = construct_vm_data(base_ip_network, drill_master_config)
  drill_workers = construct_vm_data(base_ip_network, drill_worker_config)

  File.open("dev/tmp/dnsmasq-kubernetes", "w") do |f|
    drill_masters.each do |m|
      f.puts "host-record=kubernetes,%s" % [m[:ip]]
    end
  end

  config.vm.provision :shell, privileged: true, inline:<<EOS
set -ex

echo === Installing packages ===
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  docker.io \
  dnsmasq \

echo === Setting up DNSMasq ===
ln -s /vagrant/dev/tmp/dnsmasq-kubernetes /etc/dnsmasq.d/dnsmasq-kubernetes
systemctl restart dnsmasq

echo === Reconfiguring Docker ===
ln -s /vagrant/dev/vagrant-assets/docker-daemon.json /etc/docker/daemon.json
systemctl restart docker

echo === Done ===
EOS

  drill_masters.each do |m|
    config.vm.define m[:hostname] do |c|
        c.vm.hostname = m[:hostname]
        c.vm.network "private_network", ip: m[:ip]
        c.vm.provision :shell, privileged: true, inline:<<EOS
if [ -f /vagrant/pipe.tar ]; then
  docker load -i /vagrant/pipe.tar
fi

ln -s /vagrant/drill/drill.service /etc/systemd/system/drill.service
systemctl daemon-reload
systemctl start drill
EOS
    end
  end

  drill_workers.each do |w|
    config.vm.define w[:hostname] do |c|
        c.vm.hostname = w[:hostname]
        c.vm.network "private_network", ip: w[:ip]
    end
  end
end
