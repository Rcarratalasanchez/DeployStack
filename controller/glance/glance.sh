######################
# Chapter 2 GLANCE   #
######################

# Install Service
sudo apt-get -y install glance
sudo apt-get -y install python-glanceclient 

sudo cp -p /etc/glance/glance-api.conf /etc/glance/glance-api.conf.backup
sudo cp -p /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.backup

# Config Files
GLANCE_API_CONF=/etc/glance/glance-api.conf
GLANCE_REGISTRY_CONF=/etc/glance/glance-registry.conf

SERVICE_TENANT=service
GLANCE_SERVICE_USER=glance
GLANCE_SERVICE_PASS=glance

# Create the database
MYSQL_ROOT_PASS=openstack
MYSQL_GLANCE_PASS=GLANCE_DBPASS
mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE glance;'
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$MYSQL_GLANCE_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$MYSQL_GLANCE_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "SHOW GRANTS FOR glance"

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

# Edit the /etc/glance/glance-api.conf

sudo cp glance-api.conf /etc/glance/glance-api.conf

# In the [database] section, configure database access:
# [database]
# ...
# connection = mysql://glance:GLANCE_DBPASS@controller/glance

# In the [keystone_authtoken] and [paste_deploy] sections, configure
# Identity service access:
# [keystone_authtoken]
# ...
# auth_uri = http://controller:5000/v2.0
# identity_uri = http://controller:35357
# admin_tenant_name = service
# admin_user = glance
# admin_password = GLANCE_PASS
# [paste_deploy]
# ...
# flavor = keystone

# Configure the local file system store and location of image files
# [glance_store]
# ...
# default_store = file
# filesystem_store_datadir = /var/lib/glance/images/

# Configure the noop notification driver to disable notifi-
# cations because they only pertain to the optional Telemetry service
# [DEFAULT]
# ...
# notification_driver = noop

# To assist with troubleshooting, enable verbose logging in the
# [DEFAULT]
# ...
# verbose = True

# Edit the /etc/glance/glance-registry.conf

sudo cp glance-registry.conf /etc/glance/glance-registry.conf

# In the [database] section, configure database access:
# [database]
# ...
# connection = mysql://glance:GLANCE_DBPASS@controller/glance

# In the [keystone_authtoken] and [paste_deploy] sections, configure
# Identity service access:
# [keystone_authtoken]
# ...
# auth_uri = http://controller:5000/v2.0
# identity_uri = http://controller:35357
# admin_tenant_name = service
# admin_user = glance
# admin_password = GLANCE_PASS
# [paste_deploy]
# ...
# flavor = keystone

# In the [DEFAULT] section, configure the noop notification driver to disable notifi-
# cations because they only pertain to the optional Telemetry service:
# [DEFAULT]
# ...
# notification_driver = noop

# [DEFAULT]
# ...
# verbose = True

# Populate the Image Service database:
su -s /bin/sh -c "glance-manage db_sync" glance


# Restart and delete sqlite databases

service glance-registry restart
service glance-api restart

rm -f /var/lib/glance/glance.sqlite

# Check operation

mkdir /tmp/images
cd /tmp/images
wget http://cdn.download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img

glance image-create --name "cirros-0.3.3-x86_64" --file cirros-0.3.3-x86_64-disk.img \
--disk-format qcow2 --container-format bare --is-public True --progress

# +------------------+--------------------------------------+
# | Property         | Value                                |
# +------------------+--------------------------------------+
# | checksum         | 133eae9fb1c98f45894a4e60d8736619     |
# | container_format | bare                                 |
# | created_at       | 2015-02-08T16:48:33                  |
# | deleted          | False                                |
# | deleted_at       | None                                 |
# | disk_format      | qcow2                                |
# | id               | 510cd04a-5d27-4fed-9a0b-2bd13f5fdc27 |
# | is_public        | True                                 |
# | min_disk         | 0                                    |
# | min_ram          | 0                                    |
# | name             | cirros-0.3.3-x86_64                  |
# | owner            | None                                 |
# | protected        | False                                |
# | size             | 13200896                             |
# | status           | active                               |
# | updated_at       | 2015-02-08T16:48:34                  |
# | virtual_size     | None                                 |
# +------------------+--------------------------------------+

glance image-list
# +--------------------------------------+---------------------+-------------+------------------+----------+--------+
# | ID                                   | Name                | Disk Format | Container Format | Size     | Status |
# +--------------------------------------+---------------------+-------------+------------------+----------+--------+
# | 510cd04a-5d27-4fed-9a0b-2bd13f5fdc27 | cirros-0.3.3-x86_64 | qcow2       | bare             | 13200896 | active |
# +--------------------------------------+---------------------+-------------+------------------+----------+--------+

rm -rf /tmp/images/

cd /tmp

wget http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img

glance image-create --name "trusty-image" --file trusty-server-cloudimg-amd64-disk1.img --disk-format qcow2 --container-format bare --is-public True --progress
# +------------------+--------------------------------------+
# | Property         | Value                                |
# +------------------+--------------------------------------+
# | checksum         | e5adaad20fdf3361ed86a16cecbf5b77     |
# | container_format | bare                                 |
# | created_at       | 2015-02-08T16:58:36                  |
# | deleted          | False                                |
# | deleted_at       | None                                 |
# | disk_format      | qcow2                                |
# | id               | 984cb562-e1c0-4cff-9fee-16cedc9ff249 |
# | is_public        | True                                 |
# | min_disk         | 0                                    |
# | min_ram          | 0                                    |
# | name             | trusty-image                         |
# | owner            | None                                 |
# | protected        | False                                |
# | size             | 256508416                            |
# | status           | active                               |
# | updated_at       | 2015-02-08T16:58:38                  |
# | virtual_size     | None                                 |
# +------------------+--------------------------------------+

# -> controller/nova.sh