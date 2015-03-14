#################################
# Chapter 8 NEUTRON_CONTROLLER  #
#################################

cp -p /etc/sysctl.conf /etc/sysctl.conf.backup

# Edit the /etc/sysctl.conf file to contain the following parameters:
# net.ipv4.ip_forward=1
# net.ipv4.conf.all.rp_filter=0
# net.ipv4.conf.default.rp_filter=0

## Implement the changes:
sysctl -p

apt-get -y install neutron-plugin-ml2 neutron-plugin-openvswitch-agent \
neutron-l3-agent neutron-dhcp-agent

##  To configure the Networking common components
cp -p /etc/neutron/neutron.conf /etc/neutron/neutron.conf.backup

cp -p neutron.conf /etc/neutron/neutron.conf

# In the [database] section, comment out any connection options because net-
# work nodes do not directly access the database.

# In the [DEFAULT] section, configure RabbitMQ message broker access:
# [DEFAULT]
# ...
# rpc_backend = rabbit
# rabbit_host = controller
# rabbit_password = RABBIT_PASS

# In the [DEFAULT] and [keystone_authtoken] sections, configure Identity
# service access:
# [DEFAULT]
# ...
# auth_strategy = keystone
# [keystone_authtoken]
# ...
# auth_uri = http://controller:5000/v2.0
# identity_uri = http://controller:35357
# admin_tenant_name = service
# admin_user = neutron
# admin_password = NEUTRON_PASS

# In the [DEFAULT] section, enable the Modular Layer 2 (ML2) plug-in, router ser-
# vice, and overlapping IP addresses:
# [DEFAULT]
# ...
# core_plugin = ml2
# service_plugins = router
# allow_overlapping_ips = True

# (Optional) To assist with troubleshooting, enable verbose logging in the [DE-
# FAULT] section:
# [DEFAULT]
# ...
# verbose = True

## To configure the Modular Layer 2 (ML2) plug-in
cp -p /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.backup

cp -p ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini

# In the [ml2] section, enable the flat and generic routing encapsulation (GRE) net-
# work type drivers, GRE tenant networks, and the OVS mechanism driver:
# [ml2]
# ...
# type_drivers = flat,gre
# tenant_network_types = gre
# mechanism_drivers = openvswitch

# In the [ml2_type_gre] section, configure the tunnel identifier (id) range:
# [ml2_type_gre]
# ...
# tunnel_id_ranges = 1:1000

# In the [securitygroup] section, enable security groups, enable ipset, and con-
# figure the OVS iptables firewall driver:
# [securitygroup]
# ...
# enable_security_group = True
# enable_ipset = True
# firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

# In the [ovs] section, enable tunnels and configure the local tunnel endpoint:
# [ovs]
# ...
# local_ip = INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS
# enable_tunneling = True
# bridge_mappings = external:br-ex

# Replace INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS with the IP address of
# the instance tunnels network interface on your network.

# In the [agent] section, enable GRE tunnels:
# [agent]
# ...
# tunnel_types = gre


## To configure the Layer-3 (L3) agent

cp -p /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini.backup

cp -p l3_agent.ini /etc/neutron/l3_agent.ini

# The Layer-3 (L3) agent provides routing services for virtual networks.

# Edit the /etc/neutron/l3_agent.ini file and complete the following actions:

# In the [DEFAULT] section, configure the driver, enable network namespaces, configure the 
# external network bridge and enable deletion of defunct router namespaces:

# [DEFAULT]
# ...
# interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
# use_namespaces = True
# external_network_bridge = br-ex
# router_delete_namespaces = True

# (Optional) To assist with troubleshooting, enable verbose logging in the [DE-
# FAULT] section:
# [DEFAULT]
# ...
# verbose = True

## To configure the DHCP agent

cp -p /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.backup

cp -p dhcp_agent.ini /etc/neutron/dhcp_agent.ini

# In the [DEFAULT] section, configure the drivers, enable namespaces and enable
# deletion of defunct DHCP namespaces:
# [DEFAULT]
# ...
# interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
# dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
# use_namespaces = True
# dhcp_delete_namespaces = True

# [DEFAULT]
# ...
# verbose = True

# Edit the /etc/neutron/dhcp_agent.ini file and complete the following ac-
# tion:
# •
# In the [DEFAULT] section, enable the dnsmasq configuration file:
# [DEFAULT]
# ...
# dnsmasq_config_file = /etc/neutron/dnsmasq-neutron.conf

cp dnsmasq-neutron.conf /etc/neutron

# Create and edit the /etc/neutron/dnsmasq-neutron.conf file and com-
# plete the following action:

# Enable the DHCP MTU option (26) and configure it to 1454 bytes:
# dhcp-option-force=26,1454

# Kill any existing dnsmasq processes:

pkill dnsmasq

## To configure the metadata agent
# The metadata agent provides configuration information such as credentials to instances.

cp -p /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.backup

cp -p metadata_agent.ini /etc/neutron/metadata_agent.ini

# [DEFAULT]
# ...
# auth_url = http://controller:5000/v2.0
# auth_region = regionOne
# admin_tenant_name = service
# admin_user = neutron
# admin_password = NEUTRON_PASS

# In the [DEFAULT] section, configure the metadata host:
# [DEFAULT]
# ...
# nova_metadata_ip = controller

# In the [DEFAULT] section, configure the metadata proxy shared secret:
# [DEFAULT]
# ...
# metadata_proxy_shared_secret = METADATA_SECRET

# (Optional) To assist with troubleshooting, enable verbose logging in the [DE-
# FAULT] section:
# [DEFAULT]
# ...
# verbose = True

# --> Go to Controller/Neutron/neutron.sh

##################################
# Chapter 10 OPENVSWITCH_NETWORK #
##################################

# To configure the Open vSwitch (OVS) service

# Restart the OVS service:
service openvswitch-switch restart

# Add the external bridge:
ovs-vsctl add-br br-ex

# Add a port to the external bridge that connects to the physical external network interface:
# Replace INTERFACE_NAME with the actual interface name. For example, eth2 or ens256.
ovs-vsctl add-port br-ex eth3

# Restart the Networking services:

service neutron-plugin-openvswitch-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

# -> Go to controller node/neutron.sh

## TSHOOT

# The neutron services in the network node can't connect to controller node:

# 2015-03-06 20:44:51.502 11697 TRACE neutron ImportError: No module named rabbit
# 2015-03-06 20:44:51.502 11697 TRACE neutron 

# An error occurs when set the rpc_backend to rabbit instead of leave it 
# by default, because by default is set to kombu

# Unset the rpc_backend variable and restart the services then check in the 
# controller node with neutron agent-list

# The messaging module to use, defaults to kombu.
#rpc_backend = rabbit