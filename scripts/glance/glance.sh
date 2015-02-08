######################
# Chapter 2 GLANCE   #
######################

# Install Service
sudo apt-get update
sudo apt-get -y install glance
sudo apt-get -y install python-glanceclient 

# Config Files
GLANCE_API_CONF=/etc/glance/glance-api.conf
GLANCE_REGISTRY_CONF=/etc/glance/glance-registry.conf

SERVICE_TENANT=service
GLANCE_SERVICE_USER=glance
GLANCE_SERVICE_PASS=glance

# Create the database
MYSQL_ROOT_PASS=openstack
MYSQL_GLANCE_PASS=openstack
mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE glance;'
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$MYSQL_GLANCE_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$MYSQL_GLANCE_PASS';"

source admin-openrc.sh

# Create the service credentials

keystone user-create --name glance --pass GLANCE_PASS
# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |                                  |
# | enabled  |               True               |
# |    id    | 3072f0b1e29844f8b839b9829c76a26c |
# |   name   |              glance              |
# | username |              glance              |
# +----------+----------------------------------+

keystone user-role-add --user glance --tenant service --role admin

keystone service-create --name glance --type image \
--description "OpenStack Image Service"
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |     OpenStack Image Service      |
# |   enabled   |               True               |
# |      id     | ca93998703494d6dbe9c4e12f3f29e7f |
# |     name    |              glance              |
# |     type    |              image               |
# +-------------+----------------------------------+

keystone endpoint-create \
--service-id $(keystone service-list | awk '/ image / {print $2}') \
--publicurl http://controller:9292 \
--internalurl http://controller:9292 \
--adminurl http://controller:9292 \
--region regionOne
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# |   adminurl  |      http://controller:9292      |
# |      id     | 2807d09e937c45988222bfae04e6a4f4 |
# | internalurl |      http://controller:9292      |
# |  publicurl  |      http://controller:9292      |
# |    region   |            regionOne             |
# |  service_id | ca93998703494d6dbe9c4e12f3f29e7f |
# +-------------+----------------------------------+

