##### Keystone 

### Install the Identity Service

# Install the OpenStack Identity Service on the controller node
yum install -y openstack-keystone python-keystoneclient

# Backup of the initial configuration
cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.backup

# Specify the location of the database in the configuration file.
# Pass: KEYSTONE_DBPASS
openstack-config --set /etc/keystone/keystone.conf \
sql connection mysql://keystone:KEYSTONE_DBPASS@controller/keystone

# Use the openstack-db command to create the database and tables, as well
# as a database user called keystone to connect to the database

openstack-db --init --service keystone --yes --password KEYSTONE_DBPASS --rootpw openstack

# Define an authorization token to use as a shared secret between the Identity Service
# and other OpenStack services

ADMIN_TOKEN=897305213c5960a57c74
echo $ADMIN_TOKEN

openstack-config --set /etc/keystone/keystone.conf DEFAULT \
admin_token $ADMIN_TOKEN

# By default, Keystone uses PKI tokens. Create the signing keys and certificates

keystone-manage pki_setup --keystone-user keystone --keystone-group keystone

chown -R keystone:keystone /etc/keystone/* /var/log/keystone/keystone.log

# Start the Identity Service and enable it to start when the system boots

service openstack-keystone start
chkconfig openstack-keystone on

### Define users, tenants, and roles

# We'll set OS_SERVICE_TOKEN, as well as OS_SERVICE_ENDPOINT to specify where the Identity Service is running

export OS_SERVICE_TOKEN=897305213c5960a57c74
export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0

# First, create a tenant for an administrative user and a tenant for other OpenStack services to use

keystone tenant-create --name=admin --description="Admin Tenant"

# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |           Admin Tenant           |
# |   enabled   |               True               |
# |      id     | a749885059ab42e584866875f0bf46cd |
# |     name    |              admin               |
# +-------------+----------------------------------+

keystone tenant-create --name=service --description="Service Tenant"

# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |          Service Tenant          |
# |   enabled   |               True               |
# |      id     | 1611d07fe83b4eefb4ca5e3e277b4c4e |
# |     name    |             service              |
# +-------------+----------------------------------+

# Next, create an administrative user called admin
# Pass: ADMIN_PASS

keystone user-create --name=admin --pass=ADMIN_PASS \
--email=admin@example.com

# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |        admin@example.com         |
# | enabled  |               True               |
# |    id    | 6ef07da984364b599a166eb7e1e0a7af |
# |   name   |              admin               |
# +----------+----------------------------------+


# Create a role for administrative tasks called admin. Any roles you create should map to
# roles specified in the policy.json files of the various OpenStack services

keystone role-create --name=admin

# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |    id    | db023c2371ca4c1ba482b04c248acd72 |
# |   name   |              admin               |
# +----------+----------------------------------+

# Finally, you have to add roles to users. Users always log in with a tenant, and roles are
# assigned to users within tenants. Add the admin role to the admin user when logging in
# with the admin tenant

keystone user-role-add --user=admin --tenant=admin --role=admin

## Define services and API endpoints

# Create a service entry for the Identity Service:

keystone service-create --name=keystone --type=identity \
--description="Keystone Identity Service"

# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |    Keystone Identity Service     |
# |      id     | 0ef7d881ae48442ba5adec5da93d9d91 |
# |     name    |             keystone             |
# |     type    |             identity             |
# +-------------+----------------------------------+

# Specify an API endpoint for the Identity Service by using the returned service ID. When
# you specify an endpoint, you provide URLs for the public API, internal API, and admin API

keystone endpoint-create \
--service-id=e0cca46e338445fb92704fc49983c5cc \
--publicurl=http://controller:5000/v2.0 \
--internalurl=http://controller:5000/v2.0 \
--adminurl=http://controller:35357/v2.0

+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  |   http://controller:35357/v2.0   |
|      id     | c05ae2968d164314834ee14fff8284fc |
| internalurl |   http://controller:5000/v2.0    |
|  publicurl  |   http://controller:5000/v2.0    |
|    region   |            regionOne             |
|  service_id | 0ef7d881ae48442ba5adec5da93d9d91 |
+-------------+----------------------------------+

## Verify the Identity Service installation

unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT

# Request an authentication token using the admin user and the password you chose 
# during the earlier administrative user-creation step.

keystone --os-username=admin --os-password=ADMIN_PASS \
--os-auth-url=http://controller:35357/v2.0 token-get

# verify that authorization is behaving as expected by requesting authorization on a tenant.

keystone --os-username=admin --os-password=ADMIN_PASS \
--os-tenant-name=admin --os-auth-url=http://controller:35357/v2.0 token-get

source ../../config/keystone/openrc.sh

keystone token-get

keystone user-list

# +----------------------------------+-------+---------+-------------------+
# |                id                |  name | enabled |       email       |
# +----------------------------------+-------+---------+-------------------+
# | 6ef07da984364b599a166eb7e1e0a7af | admin |   True  | admin@example.com |
# +----------------------------------+-------+---------+-------------------+
