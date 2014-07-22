##### Glance

### Install Compute controller services

yum install -y openstack-nova python-novaclient

# Backup of the nova.conf
cp -p /etc/nova/nova.conf /etc/nova/nova.conf.backup

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

