#!/usr/bin/env bash

NCOMPUTES="$1"
if [ -z "$NCOMPUTES" ] || [ "$NCOMPUTES" -lt 1 ] || [ "$NCOMPUTES" -gt 10 ]; then
    echo "You must request between 1 and 10 compute nodes ($NCOMPUTES requested)."
    exit 1
fi

COMPUTE_DEFS=""
VAGRANT_DEFS=""
for ((i=1;i<=NCOMPUTES;i++)); do
    COMPUTE_DEFS+=`cat <<EOF
c_name[$((i-1))]=c$i
c_ip[$((i-1))]=192.168.7.$((i+2))
c_mac[$((i-1))]=22:1a:2b:00:00:$((i-1))$((i-1))
EOF`
    COMPUTE_DEFS+=$'\n'
    VAGRANT_DEFS+=`cat <<EOF
    config.vm.define "c$i", autostart: false do |c$i|
      c$i.vm.network :private_network, :mac => "221a2b0000$((i-1))$((i-1))",
                     :model_type => "rtl8139",
                     :network_name => "cluster0"

      c$i.vm.provider "libvirt" do |libvirtc$i|
        libvirtc$i.memory = 2048
        libvirtc$i.cpus = 1
        libvirtc$i.boot 'network'
      end
    end
EOF`
    VAGRANT_DEFS+=$'\n'
done

cp recipe.sh.tmpl cluster/recipe.sh
sed "s/<NCOMPUTES>/$NCOMPUTES/g;" input.local.tmpl > cluster/input.local
echo "$COMPUTE_DEFS" >> cluster/input.local
cp Vagrantfile.header.tmpl cluster/Vagrantfile
echo "$VAGRANT_DEFS" >> cluster/Vagrantfile
cat Vagrantfile.footer.tmpl >> cluster/Vagrantfile
cp slurm.conf cluster/slurm.conf
cp slurmdbd.conf cluster/slurmdbd.conf
cp slurmdbd.sql cluster/slurmdbd.sql
cp slurm-setup.sh cluster/slurm-setup.sh
cp cgroup.conf cluster/cgroup.conf
cp cgroup_allowed_devices_file.conf cluster/cgroup_allowed_devices_file.conf
