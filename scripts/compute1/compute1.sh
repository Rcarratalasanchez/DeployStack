##### Compute1

# Networking must to be special if you use vagrant
# Use different IP addresses when you configure eth0. This guide uses
# 192.168.0.11 for the internal network. Do not configure eth1 with a static IP
# address. The networking component of OpenStack assigns and configures an IP address

# Must to sure that the eth1 is with DCHP -> manual solution: change in virtualbox the eth2 and asign NAT
# After change the ifcg-eth1 and set dhcp
# INFO: if the machine falls down the DCHP won't work! Start the VM with Virtualbox and NOT with vagrant up

### Pre-install

# Change the etc/hosts

cp ../../config/pre/hosts /etc/hosts
hostname compute1

yum install -y ntp
service ntpd start
chkconfig ntpd on

yum install -y mysql MySQL-python

# To enable the RDO repository, download and install the rdo-release-havana package
yum install -y http://repos.fedorapeople.org/repos/openstack/openstack-havana/rdo-release-havana-7.noarch.rpm

# Install the latest epel-release package
yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

# Install openstack-utils. This verifies that you can access the RDO repository
yum install -y openstack-utils

### Compute packages

yum install -y openstack-nova-compute

openstack-config --set /etc/nova/nova.conf database connection mysql://nova:NOVA_DBPASS@controller/nova

openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone

openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_host controller

openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_protocol http

openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_port 35357

openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_user nova

openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service

openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_password NOVA_PASS

# Configure the Compute Service to use the Qpid message broker by setting these configuration keys

openstack-config --set /etc/nova/nova.conf \
DEFAULT rpc_backend nova.openstack.common.rpc.impl_qpid

openstack-config --set /etc/nova/nova.conf DEFAULT qpid_hostname controller

# Configure Compute to provide remote console access to instances

openstack-config --set /etc/nova/nova.conf DEFAULT my_ip 192.168.0.11

openstack-config --set /etc/nova/nova.conf DEFAULT vnc_enabled True

openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0

openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address 192.168.0.11

openstack-config --set /etc/nova/nova.conf DEFAULT novncproxy_base_url http://controller:6080/vnc_auto.html

# Specify the host that runs the Image Service.
openstack-config --set /etc/nova/nova.conf DEFAULT glance_host controller

# Edit the /etc/nova/api-paste.ini file to add the credentials to the [filter:authtoken] section

# [filter:authtoken]
# paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
# auth_host = controller
# auth_port = 35357
# auth_protocol = http
# admin_tenant_name = service
# admin_user = nova
# admin_password = NOVA_PASS

### Enable networking

yum install -y openstack-nova-network

# Edit the nova.conf file to define the networking mode

openstack-config --set /etc/nova/nova.conf DEFAULT \
network_manager nova.network.manager.FlatDHCPManager

openstack-config --set /etc/nova/nova.conf DEFAULT \
firewall_driver nova.virt.libvirt.firewall.IptablesFirewallDriver

openstack-config --set /etc/nova/nova.conf DEFAULT network_size 254

openstack-config --set /etc/nova/nova.conf DEFAULT allow_same_net_traffic False

openstack-config --set /etc/nova/nova.conf DEFAULT multi_host True

openstack-config --set /etc/nova/nova.conf DEFAULT send_arp_for_ha True

openstack-config --set /etc/nova/nova.conf DEFAULT share_dhcp_address True

openstack-config --set /etc/nova/nova.conf DEFAULT force_dhcp_release

openstack-config --set /etc/nova/nova.conf DEFAULT flat_interface eth1

openstack-config --set /etc/nova/nova.conf DEFAULT flat_network_bridge br100

openstack-config --set /etc/nova/nova.conf DEFAULT public_interface eth1

# Provide a local metadata service that is reachable from instances on this compute
# node. Perform this step only on compute nodes that do not run the nova-api service.

yum install -y openstack-nova-api
service openstack-nova-metadata-api start
chkconfig openstack-nova-metadata-api on

# Start the network service and configure it to start when the system boots:

service openstack-nova-network start
chkconfig openstack-nova-network on

source openrc.sh

# This command must to be particularized!
# nova network-create vmnet --fixed-range-v4=10.0.0.0/24 \
# --bridge=br100 --multi-host=T

# WARNING! The error WARNING nova.openstack.common.db.sqlalchemy.session 
# [req-37781ed4-896d-450b-aa10-4330afe7e7d6 None None] SQL connection failed. infinite attempts left.
# is related with iptables: sudo service iptables stop in both controllers will fixed this!

sudo nova-manage network create vmnet --fixed_range_v4=10.0.0.0/24 --network_size=64 --bridge_interface=eth1