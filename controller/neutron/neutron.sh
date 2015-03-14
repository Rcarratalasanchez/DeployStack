#################################
# Chapter 7 NEUTRON_CONTROLLER  #
#################################

## Config Files & Vars
NEUTRON_CONF=/etc/neutron/neutron.conf
MYSQL_HOST=controller
MYSQL_ROOT_PASS=openstack
MYSQL_NEUTRON_PASS=NEUTRON_DBPASS

## To create the database
mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE neutron;'
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$MYSQL_NEUTRON_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$MYSQL_NEUTRON_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "SHOW GRANTS FOR neutron"

source admin-openrc.sh

## Create the neutron user:
keystone user-create --name neutron --pass NEUTRON_PASS
# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |                                  |
# | enabled  |               True               |
# |    id    | 80422dad4274423695fa44cb0efe0ea4 |
# |   name   |             neutron              |
# | username |             neutron              |
# +----------+----------------------------------+

## Add the admin role to the neutron user:
keystone user-role-add --user neutron --tenant service --role admin

## Create the neutron service entity
keystone service-create --name neutron --type network \
--description "OpenStack Networking"
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |       OpenStack Networking       |
# |   enabled   |               True               |
# |      id     | cb312f60266344e6bc3ce132e6337331 |
# |     name    |             neutron              |
# |     type    |             network              |
# +-------------+----------------------------------+

## Create the Networking service API endpoints:
keystone endpoint-create \
--service-id $(keystone service-list | awk '/ network / {print $2}') \
--publicurl http://controller:9696 \
--adminurl http://controller:9696 \
--internalurl http://controller:9696 \
--region regionOne
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# |   adminurl  |      http://controller:9696      |
# |      id     | 9867de46499a4dfab086e9c467bbc476 |
# | internalurl |      http://controller:9696      |
# |  publicurl  |      http://controller:9696      |
# |    region   |            regionOne             |
# |  service_id | cb312f60266344e6bc3ce132e6337331 |
# +-------------+----------------------------------+

## Install networking components
apt-get -y install neutron-server neutron-plugin-ml2 python-neutronclient

cp -p /etc/neutron/neutron.conf /etc/neutron/neutron.conf.backup

cp -p neutron.conf /etc/neutron/neutron.conf

SERVICE_ADMIN=$(keystone tenant-get service | awk '/ id / {print $4}')

sudo sed -i "s/^# nova_admin_tenant_id =.*/nova_admin_tenant_id = ${SERVICE_ADMIN}/" ${NEUTRON_CONF}

# In the [database] section, configure database access:
# [database]
# ...
# connection = mysql://neutron:NEUTRON_DBPASS@controller/neutron

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

# In the [DEFAULT] section, configure Networking to notify Compute of network
# topology changes:
# [DEFAULT]
# ...
# notify_nova_on_port_status_changes = True
# notify_nova_on_port_data_changes = True
# nova_url = http://controller:8774/v2
# nova_admin_auth_url = http://controller:35357/v2.0
# nova_region_name = regionOne
# nova_admin_username = nova
# nova_admin_tenant_id = SERVICE_TENANT_ID
# nova_admin_password = NOVA_PASS

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

## To configure Compute to use Networking
cp -p ../nova/nova.conf /etc/nova/nova.conf

# [DEFAULT]
# ...
# network_api_class = nova.network.neutronv2.api.API
# security_group_api = neutron
# linuxnet_interface_driver = nova.network.linux_net.
# LinuxOVSInterfaceDriver
# firewall_driver = nova.virt.firewall.NoopFirewallDriver

# [neutron]
# ...
# url = http://controller:9696
# auth_strategy = keystone
# admin_auth_url = http://controller:35357/v2.0
# admin_tenant_name = service
# admin_username = neutron
# admin_password = NEUTRON_PASS

## Populate the database:
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
--config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno" neutron

## Restart the Compute services:

service nova-api restart
service nova-scheduler restart
service nova-conductor restart

## Restart the Networking service:
service neutron-server restart

## Verify operation:
source admin-openrc

neutron ext-list
# +-----------------------+-----------------------------------------------+
# | alias                 | name                                          |
# +-----------------------+-----------------------------------------------+
# | security-group        | security-group                                |
# | l3_agent_scheduler    | L3 Agent Scheduler                            |
# | ext-gw-mode           | Neutron L3 Configurable external gateway mode |
# | binding               | Port Binding                                  |
# | provider              | Provider Network                              |
# | agent                 | agent                                         |
# | quotas                | Quota management support                      |
# | dhcp_agent_scheduler  | DHCP Agent Scheduler                          |
# | l3-ha                 | HA Router extension                           |
# | multi-provider        | Multi Provider Network                        |
# | external-net          | Neutron external network                      |
# | router                | Neutron L3 Router                             |
# | allowed-address-pairs | Allowed Address Pairs                         |
# | extraroute            | Neutron Extra Route                           |
# | extra_dhcp_opt        | Neutron Extra DHCP opts                       |
# | dvr                   | Distributed Virtual Router                    |
# +-----------------------+-----------------------------------------------+

#################################
# Chapter 9 METADATA_NEUTRON    #
#################################

# On the controller node, edit the /etc/nova/nova.conf file and complete the fol-
# lowing action:

# In the [neutron] section, enable the metadata proxy and configure the secret:
# [neutron]
# ...
# service_metadata_proxy = True
# metadata_proxy_shared_secret = METADATA_SECRET
# Replace METADATA_SECRET with the secret you chose for the metadata proxy.

# On the controller node, restart the Compute API service:
service nova-api restart

####################################
# Chapter 11 VERIFICATION NEUTRON  #
####################################

source admin-openrc.sh

# List agents to verify successful launch of the neutron agents:
neutron-agent list


