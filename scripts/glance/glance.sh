##### Glance

### Install the Image Service

yum install -y openstack-glance

# NOTE: the openrc.sh must to be sourced

# The Image Service provides the glance-
# api and glance-registry services, each with its own configuration file.

openstack-config --set /etc/glance/glance-api.conf \
DEFAULT sql_connection mysql://glance:GLANCE_DBPASS@controller/glance

openstack-config --set /etc/glance/glance-registry.conf \
DEFAULT sql_connection mysql://glance:GLANCE_DBPASS@controller/glance

# create the Image Service database and tables and a glance database user
# TSHOOT: if can't connect to the database, verify that the /etc/hosts have the correct DNS

openstack-db --init --service glance --yes --password GLANCE_DBPASS --rootpw openstack 

# Create a glance user that the Image Service can use to authenticate with the Identity Service

keystone user-create --name=glance --pass=GLANCE_PASS \
> --email=glance@example.com

# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |        glance@example.com        |
# | enabled  |               True               |
# |    id    | 4f43cfe8d5024c17bc7fcbacadec6e3f |
# |   name   |              glance              |
# +----------+----------------------------------+

# Use the service tenant and give the user the admin role

keystone user-role-add --user=glance --tenant=service --role=admin

# Configure the Image Service to use the Identity Service for authentication

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
auth_uri http://controller:5000

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
auth_host controller

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
admin_tenant_name service

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
admin_user glance

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
admin_password GLANCE_PASS

openstack-config --set /etc/glance/glance-api.conf paste_deploy \
flavor keystone

openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
auth_uri http://controller:5000

openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
auth_host controller

openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
admin_tenant_name service

openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
admin_user glance

openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
admin_password GLANCE_PASS

openstack-config --set /etc/glance/glance-registry.conf paste_deploy \
flavor keystone


# Add the credentials to the /etc/glance/glance-api-paste.ini and /etc/
# glance/glance-registry-paste.ini files

cp /usr/share/glance/glance-api-dist-paste.ini /etc/glance/glance-api-paste.ini

cp /usr/share/glance/glance-registry-dist-paste.ini /etc/glance/glance-registry-paste.ini

# NOTE: the edited files are in config/glance/
# cp ../../config/glance/glance-api-dist-paste.ini /etc/glance/glance-api-paste.ini
# cp ../../config/glance/glance-registry-dist-paste.ini /etc/glance/glance-registry-paste.ini

# Register the Image Service with the Identity Service so that other OpenStack services
# can locate it. Register the service and create the endpoint:

keystone service-create --name=glance --type=image \
--description="Glance Image Service"

# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |       Glance Image Service       |
# |      id     | b08373fcdcb545a5a7ba96a5cdbe9c52 |
# |     name    |              glance              |
# |     type    |              image               |
# +-------------+----------------------------------+

# Use the id property returned for the service to create the endpoint

keystone endpoint-create \
--service-id=b08373fcdcb545a5a7ba96a5cdbe9c52 \
--publicurl=http://controller:9292 \
--internalurl=http://controller:9292 \
--adminurl=http://controller:9292

# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# |   adminurl  |      http://controller:9292      |
# |      id     | 82cede823c3b41abb85c040345d7adea |
# | internalurl |      http://controller:9292      |
# |  publicurl  |      http://controller:9292      |
# |    region   |            regionOne             |
# |  service_id | b08373fcdcb545a5a7ba96a5cdbe9c52 |
# +-------------+----------------------------------+

# Start the glance-api and glance-registry services and configure them to start when the system boots

service openstack-glance-api start
service openstack-glance-registry start
chkconfig openstack-glance-api on
chkconfig openstack-glance-registry on

### Verify the Image Service installation

mkdir images
cd images/
wget http://cdn.download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img

# Upload the image to the Image Service:

# Example:  glance image-create --name=imageLabel --disk-format=fileFormat \
# 			--container-format=containerFormat --is-public=accessValue < imageFile

glance image-create --name="CirrOS 0.3.1" --disk-format=qcow2 \
--container-format=bare --is-public=true < cirros-0.3.1-x86_64-disk.img

# +------------------+--------------------------------------+
# | Property         | Value                                |
# +------------------+--------------------------------------+
# | checksum         | d972013792949d0d3ba628fbe8685bce     |
# | container_format | bare                                 |
# | created_at       | 2014-07-22T22:39:55                  |
# | deleted          | False                                |
# | deleted_at       | None                                 |
# | disk_format      | qcow2                                |
# | id               | f2e4d06b-0a0f-46b4-9204-374f7c7e8234 |
# | is_public        | True                                 |
# | min_disk         | 0                                    |
# | min_ram          | 0                                    |
# | name             | CirrOS 0.3.1                         |
# | owner            | 75a2f462a05a4819898121ecc62195b7     |
# | protected        | False                                |
# | size             | 13147648                             |
# | status           | active                               |
# | updated_at       | 2014-07-22T22:39:55                  |
# +------------------+--------------------------------------+

glance image-list
# +--------------------------------------+--------------+-------------+------------------+----------+--------+
# | ID                                   | Name         | Disk Format | Container Format | Size     | Status |
# +--------------------------------------+--------------+-------------+------------------+----------+--------+
# | f2e4d06b-0a0f-46b4-9204-374f7c7e8234 | CirrOS 0.3.1 | qcow2       | bare             | 13147648 | active |
# +--------------------------------------+--------------+-------------+------------------+----------+--------+

