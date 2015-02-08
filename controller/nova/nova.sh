######################
# Chapter 3 COMPUTE  #
######################

# Create database

MYSQL_HOST=${ETH3_IP}
GLANCE_HOST=${ETH3_IP}
KEYSTONE_ENDPOINT=${ETH3_IP}
SERVICE_TENANT=service
NOVA_SERVICE_USER=nova
NOVA_SERVICE_PASS=nova

MYSQL_ROOT_PASS=openstack
MYSQL_NOVA_PASS=NOVA_DBPASS

mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE nova;'
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$MYSQL_NOVA_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$MYSQL_NOVA_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "SHOW GRANTS FOR nova"
# +-----------------------------------------------------------------------------------------------------+
# | Grants for nova@%                                                                                   |
# +-----------------------------------------------------------------------------------------------------+
# | GRANT USAGE ON *.* TO 'nova'@'%' IDENTIFIED BY PASSWORD '*B79B482785488AB91D97EAFCAD7BA8839EF65AD3' |
# | GRANT ALL PRIVILEGES ON `nova`.* TO 'nova'@'%'                                                      |
# +-----------------------------------------------------------------------------------------------------+

source admin-openrc.sh

keystone user-create --name nova --pass NOVA_PASS
# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |                                  |
# | enabled  |               True               |
# |    id    | 9c57f3f2451b46dc8f9f02ecdcca73ad |
# |   name   |               nova               |
# | username |               nova               |
# +----------+----------------------------------+

keystone user-role-add --user nova --tenant service --role admin

keystone service-create --name nova --type compute \
--description "OpenStack Compute"
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |        OpenStack Compute         |
# |   enabled   |               True               |
# |      id     | c7fdca8fe1af46b5877f715284d73e32 |
# |     name    |               nova               |
# |     type    |             compute              |
# +-------------+----------------------------------+

keystone endpoint-create \
--service-id $(keystone service-list | awk '/ compute / {print $2}') \
--publicurl http://controller:8774/v2/%\(tenant_id\)s \
--internalurl http://controller:8774/v2/%\(tenant_id\)s \
--adminurl http://controller:8774/v2/%\(tenant_id\)s \
--region regionOne
# +-------------+-----------------------------------------+
# |   Property  |                  Value                  |
# +-------------+-----------------------------------------+
# |   adminurl  | http://controller:8774/v2/%(tenant_id)s |
# |      id     |     5d45a210d9ee4de1ac622ac186af78a5    |
# | internalurl | http://controller:8774/v2/%(tenant_id)s |
# |  publicurl  | http://controller:8774/v2/%(tenant_id)s |
# |    region   |                regionOne                |
# |  service_id |     c7fdca8fe1af46b5877f715284d73e32    |
# +-------------+-----------------------------------------+

apt-get install -y nova-api nova-cert nova-conductor nova-consoleauth \
nova-novncproxy nova-scheduler python-novaclient

# Backup
cp -p /etc/nova/nova.conf /etc/nova/nova.conf.backup

# Edit the nova.conf file
sudo cp nova.conf /etc/nova/nova.conf

# Populate the database
su -s /bin/sh -c "nova-manage db sync" nova

service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

rm -f /var/lib/nova/nova.sqlite

# -> compute/preinstall.sh

