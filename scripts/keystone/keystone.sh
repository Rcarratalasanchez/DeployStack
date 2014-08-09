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
# |      id     | b82272c59f6a4b109c62b0cb2344f377 |
# |     name    |              admin               |
# +-------------+----------------------------------+

keystone tenant-create --name=service --description="Service Tenant"

# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |          Service Tenant          |
# |   enabled   |               True               |
# |      id     | 26897dfe88874d6f97661af6753176dc |
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
# |    id    | 125c892824d1480e80093f04f007ffea |
# |   name   |              admin               |
# +----------+----------------------------------+

# Create a role for administrative tasks called admin. Any roles you create should map to
# roles specified in the policy.json files of the various OpenStack services

keystone role-create --name=admin

# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |    id    | 0b08ea1611664ffc8c71d237c0105fd8 |
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
# |      id     | 174e7377f6124869aa1fbcd452f3fa44 |
# |     name    |             keystone             |
# |     type    |             identity             |
# +-------------+----------------------------------+

# Specify an API endpoint for the Identity Service by using the returned service ID. When
# you specify an endpoint, you provide URLs for the public API, internal API, and admin API

keystone endpoint-create \
--service-id=174e7377f6124869aa1fbcd452f3fa44 \
--publicurl=http://controller:5000/v2.0 \
--internalurl=http://controller:5000/v2.0 \
--adminurl=http://controller:35357/v2.0

# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# |   adminurl  |   http://controller:35357/v2.0   |
# |      id     | 1bcdebb2b8274a3c98995a028180e6b0 |
# | internalurl |   http://controller:5000/v2.0    |
# |  publicurl  |   http://controller:5000/v2.0    |
# |    region   |            regionOne             |
# |  service_id | 174e7377f6124869aa1fbcd452f3fa44 |
# +-------------+----------------------------------+

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
# | 125c892824d1480e80093f04f007ffea | admin |   True  | admin@example.com |
# +----------------------------------+-------+---------+-------------------+

# -> glance.sh