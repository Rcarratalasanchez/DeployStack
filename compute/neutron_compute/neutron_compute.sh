##################################
# Chapter 11 OPENVSWITCH_NETWORK #
##################################

## To configure the Networking common components

cp -p /etc/sysctl.conf /etc/sysctl.conf.backup

cp sysctl.conf /etc/sysctl.conf
# Edit the /etc/sysctl.conf file to contain the following parameters:
# net.ipv4.conf.all.rp_filter=0
# net.ipv4.conf.default.rp_filter=0

sysctl -p

apt-get -y install neutron-plugin-ml2 neutron-plugin-openvswitch-agent

cp -p /etc/neutron/neutron.conf /etc/neutron/neutron.conf.backup

cp -p neutron.conf /etc/neutron/neutron.conf

# In the [database] section, comment out any connection options because
# compute nodes do not directly access the database.

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

# The ML2 plug-in uses the Open vSwitch (OVS) mechanism (agent) to build the virtual net-
# working framework for instances.

# Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file and complete the fol-
# lowing actions:

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
# firewall_driver = neutron.agent.linux.iptables_firewall.
# OVSHybridIptablesFirewallDriver

# In the [ovs] section, enable tunnels and configure the local tunnel endpoint:
# [ovs]
# ...
# local_ip = INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS
# enable_tunneling = True
# Replace INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS with the IP address of
# the instance tunnels network interface on your compute node.


## To configure the Open vSwitch (OVS) service
# The OVS service provides the underlying virtual networking framework for instances.
# Restart the OVS service:
service openvswitch-switch restart

## To configure Compute to use Networking

# By default, distribution packages configure Compute to use legacy networking. You must
# reconfigure Compute to manage networks through Networking.

cp -p ../nova_compute/nova.conf /etc/nova/nova.conf

# Edit the /etc/nova/nova.conf file and complete the following actions:

# In the [DEFAULT] section, configure the APIs and drivers:

# [DEFAULT]
# ...
# network_api_class = nova.network.neutronv2.api.API
# security_group_api = neutron
# linuxnet_interface_driver = nova.network.linux_net.
# LinuxOVSInterfaceDriver
# firewall_driver = nova.virt.firewall.NoopFirewallDriver

# In the [neutron] section, configure access parameters:

# [neutron]
# ...
# url = http://controller:9696
# auth_strategy = keystone
# admin_auth_url = http://controller:35357/v2.0
# admin_tenant_name = service
# admin_username = neutron
# admin_password = NEUTRON_PASS

## To finalize the installation
# Restart the Compute service:
service nova-compute restart

# Restart the Open vSwitch (OVS) agent:
service neutron-plugin-openvswitch-agent restart

# -> Go to Chapter 12 controller/neutron/create_initial_network.sh
