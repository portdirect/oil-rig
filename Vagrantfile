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
    count: 0,
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
  chrony \
  docker.io \
  dnsmasq \
  socat \

export CNI_VERSION=v0.5.2
mkdir -p /opt/cni/bin
curl -sL https://github.com/containernetworking/cni/releases/download/$CNI_VERSION/cni-amd64-$CNI_VERSION.tgz | tar -zxv -C /opt/cni/bin/

echo === Setting up DNSMasq ===
ln -s /vagrant/dev/tmp/dnsmasq-kubernetes /etc/dnsmasq.d/dnsmasq-kubernetes
systemctl restart dnsmasq

echo === Syncing common assets ===
rsync -r /vagrant/dev/assets/common/ /

systemctl restart docker

if [ -f /vagrant/pipe.tar ]; then
  echo === Loading updated pipe image ===
  docker load -i /vagrant/pipe.tar
fi
EOS

  drill_masters.each do |m|
    config.vm.define m[:hostname] do |c|
        c.vm.hostname = m[:hostname]
        c.vm.network "private_network", ip: m[:ip]

        c.vm.provider "virtualbox" do |vb|
          vb.cpus = 2
          vb.memory = "2048"
        end

        c.vm.provision :shell, privileged: true, inline:<<EOS
set -ex

echo === Syncing specific assets ===
rsync -r /vagrant/dev/assets/master/ /

ln -s /vagrant/drill/drill.service /etc/systemd/system/drill.service
systemctl daemon-reload
systemctl start drill

echo === Done provisioning master ===
EOS
    end
  end

  drill_workers.each do |w|
    config.vm.define w[:hostname] do |c|
        c.vm.hostname = w[:hostname]
        c.vm.network "private_network", ip: w[:ip]

        c.vm.provider "virtualbox" do |vb|
          vb.cpus = 1
          vb.memory = "1024"
        end

        c.vm.provision :shell, privileged: true, inline:<<EOS
set -ex

echo === Syncing specific assets ===
rsync -r /vagrant/dev/assets/worker/ /

ln -s /vagrant/drill/drill.service /etc/systemd/system/drill.service
systemctl daemon-reload
systemctl start drill

echo === Done provisioning worker ===
EOS
    end
  end
end
