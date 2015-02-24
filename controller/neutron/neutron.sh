#################################
# Chapter 7 NEUTRON_CONTROLLER  #
#################################

# Config Files & Vars
NEUTRON_CONF=/etc/neutron/neutron.conf
MYSQL_HOST=controller
MYSQL_ROOT_PASS=openstack
MYSQL_NEUTRON_PASS=NEUTRON_DBPASS

# To create the database
mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE neutron;'
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$MYSQL_NEUTRON_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$MYSQL_NEUTRON_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "SHOW GRANTS FOR neutron"

source admin-openrc.sh

# Create the neutron user:
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

# Add the admin role to the neutron user:
keystone user-role-add --user neutron --tenant service --role admin

# Create the neutron service entity
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

# Create the Networking service API endpoints:
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

# Install networking components
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

### IMPORTANT!!! Replace SERVICE_TENANT_ID with the service tenant identifier (id)

