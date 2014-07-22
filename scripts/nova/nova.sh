##### Glance

### Install Compute controller services

yum install -y openstack-nova python-novaclient

# Backup of the nova.conf
cp -p /etc/nova/nova.conf /etc/nova/nova.conf.backup
cp -p /etc/nova/api-paste.ini /etc/nova/api-paste.ini.backup

# Configure the location of the database

openstack-config --set /etc/nova/nova.conf \
database connection mysql://nova:NOVA_DBPASS@controller/nova

# Set these configuration keys to configure Compute to use the Qpid message broker

openstack-config --set /etc/nova/nova.conf \
DEFAULT rpc_backend nova.openstack.common.rpc.impl_qpid

openstack-config --set /etc/nova/nova.conf DEFAULT
qpid_hostname controller

# create the Compute service database and tables and a nova database user

openstack-db --init --service nova --password NOVA_DBPASS --yes --rootpw openstack

# Set the my_ip, vncserver_listen, and vncserver_proxyclient_address
# configuration options to the internal IP address of the controller node:

openstack-config --set /etc/nova/nova.conf DEFAULT my_ip 192.168.0.10
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen 192.168.0.10
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address 192.168.0.10

# Create a nova user that Compute uses to authenticate with the Identity Service. Use
# the service tenant and give the user the admin role

keystone user-create --name=nova --pass=NOVA_PASS --email=nova@example.com

# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |         nova@example.com         |
# | enabled  |               True               |
# |    id    | fecef2e573e34587a08e6bbe768ff442 |
# |   name   |               nova               |
# +----------+----------------------------------+

keystone user-role-add --user=nova --tenant=service --role=admin

# Configure Compute to use these credentials with the Identity Service running on the controller

openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone

openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_host controller

openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_protocol http

openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_port 35357

openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_user nova

openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service

openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_password NOVA_PASS

# Add the credentials to the /etc/nova/api-paste.ini file. Add these options to
# the [filter:authtoken] section

# [filter:authtoken]
# paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
# auth_host = controller
# auth_port = 35357
# auth_protocol = http
# auth_uri = http://controller:5000/v2.0
# admin_tenant_name = service
# admin_user = nova
# admin_password = NOVA_PASS

cp -p ../../config/nova/api-paste.ini /etc/nova/api-paste.ini

# FIXME! Ensure that the api_paste_config=/etc/nova/api-paste.ini
# option is set in the /etc/nova/nova.conf file

keystone service-create --name=nova --type=compute \
--description="Nova Compute service"

# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |       Nova Compute service       |
# |      id     | e6d913b5b6354d24967c3b20a6418983 |
# |     name    |               nova               |
# |     type    |             compute              |
# +-------------+----------------------------------+

# Use the id property that is returned to create the endpoint

keystone endpoint-create \
--service-id=e6d913b5b6354d24967c3b20a6418983 \
--publicurl=http://controller:8774/v2/%\(tenant_id\)s \
--internalurl=http://controller:8774/v2/%\(tenant_id\)s \
--adminurl=http://controller:8774/v2/%\(tenant_id\)s

# +-------------+-----------------------------------------+
# |   Property  |                  Value                  |
# +-------------+-----------------------------------------+
# |   adminurl  | http://controller:8774/v2/%(tenant_id)s |
# |      id     |     9941b27ed586414ea7726a8cb8d75fa6    |
# | internalurl | http://controller:8774/v2/%(tenant_id)s |
# |  publicurl  | http://controller:8774/v2/%(tenant_id)s |
# |    region   |                regionOne                |
# |  service_id |     e6d913b5b6354d24967c3b20a6418983    |
# +-------------+-----------------------------------------+

# Start Compute services and configure them to start when the system boots:

service openstack-nova-api start
service openstack-nova-cert start
service openstack-nova-consoleauth start
service openstack-nova-scheduler start
service openstack-nova-conductor start
service openstack-nova-novncproxy start
chkconfig openstack-nova-api on
chkconfig openstack-nova-cert on
chkconfig openstack-nova-consoleauth on
chkconfig openstack-nova-scheduler on
chkconfig openstack-nova-conductor on
chkconfig openstack-nova-novncproxy on

# To verify your configuration
nova image-list

# +--------------------------------------+--------------+--------+--------+
# | ID                                   | Name         | Status | Server |
# +--------------------------------------+--------------+--------+--------+
# | f2e4d06b-0a0f-46b4-9204-374f7c7e8234 | CirrOS 0.3.1 | ACTIVE |        |
# +--------------------------------------+--------------+--------+--------+

# -> compute1