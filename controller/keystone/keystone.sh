######################
# Chapter 1 KEYSTONE #
######################

# Config Files & Vars
KEYSTONE_CONF=/etc/keystone/keystone.conf
SSL_PATH=/etc/ssl/

MYSQL_HOST=controller
MYSQL_ROOT_PASS=openstack
MYSQL_KEYSTONE_PASS=openstack

# To create the database
mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE keystone;'
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$MYSQL_KEYSTONE_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$MYSQL_KEYSTONE_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "SHOW GRANTS FOR keystone"

# Install components
apt-get install -y keystone python-keystoneclient

cp -p /etc/keystone/keystone.conf /etc/keystone/keystone.conf.backup

# Modify the config file

# sudo sed -i "s#^connection.*#connection = mysql://keystone:${MYSQL_KEYSTONE_PASS}@${MYSQL_HOST}/keystone#" ${KEYSTONE_CONF}
# sudo sed -i 's/^#admin_token.*/admin_token = ADMIN/' ${KEYSTONE_CONF}
# sudo sed -i 's,^#log_dir.*,log_dir = /var/log/keystone,' ${KEYSTONE_CONF}
# sudo sed -i 's/^#verbose.*/verbose=true/' ${KEYSTONE_CONF}
# sudo sed -i 's/^#provider.*/provider = keystone.token.providers.uuid.Provider/' ${KEYSTONE_CONF}
# sudo sed -i 's/^#driver=keystone.token.*/driver=keystone.token.persistence.backends.sql.Token/' ${KEYSTONE_CONF}

sudo cp -p keystone.conf /etc/keystone/keystone.conf

# Populate the Keystone DB
su -s /bin/sh -c "keystone-manage db_sync" keystone

service keystone restart

rm -f /var/lib/keystone/keystone.db

(crontab -l -u keystone 2>&1 | grep -q token_flush) || \
echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' \
>> /var/spool/cron/crontabs/keystone

# Config prerequisites
export OS_SERVICE_TOKEN=ADMIN
export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0

# [ADMIN]

# Create admin tenant
keystone tenant-create --name admin --description "Admin Tenant"
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |           Admin Tenant           |
# |   enabled   |               True               |
# |      id     | 106f9551e8214b4e97d9c7a1fe935a81 |
# |     name    |              admin               |
# +-------------+----------------------------------+

# Create admin user
keystone user-create --name admin --pass ADMIN_PASS --email EMAIL_ADDRESS
# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |          EMAIL_ADDRESS           |
# | enabled  |               True               |
# |    id    | 99ce47fd50be49cda908059b33f671b3 |
# |   name   |              admin               |
# | username |              admin               |
# +----------+----------------------------------+

# Create admin role
keystone role-create --name admin
# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |    id    | a384bf51990147c4bcb75e46af7d1d65 |
# |   name   |              admin               |
# +----------+----------------------------------+

# Add the admin role to the admin tenant and user
keystone user-role-add --user admin --tenant admin --role admin

# [DEMO]

# Create demo tenant
keystone tenant-create --name demo --description "Demo Tenant"
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |           Demo Tenant            |
# |   enabled   |               True               |
# |      id     | e639ec0f60084f36910a76cfcfe42e77 |
# |     name    |               demo               |
# +-------------+----------------------------------+

# Create demo user
keystone user-create --name demo --tenant demo --pass DEMO_PASS --email EMAIL_ADDRESS
# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |           EMAIL_ADDRES           |
# | enabled  |               True               |
# |    id    | 95a57b849d32434ea8bf2ad4dc93de7e |
# |   name   |               demo               |
# | tenantId | e639ec0f60084f36910a76cfcfe42e77 |
# | username |               demo               |
# +----------+----------------------------------+

# [INFO]Using the --tenant option automatically assigns the _member_ role
# to a user. This option will also create the _member_ role if it does not exist

# [ROBER]

# Create rober tenant
keystone tenant-create --name rober --description "Rober Tenant"
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |           Rober Tenant           |
# |   enabled   |               True               |
# |      id     | bde34c68c83a4bcbbf89d16c4876ef2d |
# |     name    |              rober               |
# +-------------+----------------------------------+

keystone user-create --name rober --tenant rober --pass ROBER_PASS --email EMAIL_ADDRESS
# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |          EMAIL_ADDRESS           |
# | enabled  |               True               |
# |    id    | 6036a39864b048aaa11fa102821f670b |
# |   name   |              rober               |
# | tenantId | bde34c68c83a4bcbbf89d16c4876ef2d |
# | username |              rober               |
# +----------+----------------------------------+

# Create service tenant
keystone tenant-create --name service --description "Service Tenant"
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |          Service Tenant          |
# |   enabled   |               True               |
# |      id     | 3427d7d1a0f647b3bcdf65807ca1a898 |
# |     name    |             service              |
# +-------------+----------------------------------+

# [INFO] OpenStack services also require a tenant, user, and role to interact with other services.
# Each service typically requires creating one or more unique users with the admin role
# under the service tenant.

# Create service entity and API endpoints
keystone service-create --name keystone --type identity \
--description "OpenStack Identity"
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |        OpenStack Identity        |
# |   enabled   |               True               |
# |      id     | a84d4f5c15134163a0c6d2c52d985da3 |
# |     name    |             keystone             |
# |     type    |             identity             |
# +-------------+----------------------------------+

# Create the Identity service API endpoints
keystone endpoint-create \
--service-id $(keystone service-list | awk '/ identity / {print $2}') \
--publicurl http://controller:5000/v2.0 \
--internalurl http://controller:5000/v2.0 \
--adminurl http://controller:35357/v2.0 \
--region regionOne
# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# |   adminurl  |   http://controller:35357/v2.0   |
# |      id     | afaed163e88b4a35b19c6b175f0a54de |
# | internalurl |   http://controller:5000/v2.0    |
# |  publicurl  |   http://controller:5000/v2.0    |
# |    region   |            regionOne             |
# |  service_id | a84d4f5c15134163a0c6d2c52d985da3 |
# +-------------+----------------------------------+

# OpenStack provides three API endpoint variations for each service: admin, internal,
# and public. In a production environment, the variants might reside on separate net-
# works that service different types of users for security reasons. Also, OpenStack sup-
# ports multiple regions for scalability. For simplicity, this configuration uses the manage-
# ment network for all endpoint variations and the regionOne region.

unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT

keystone --os-tenant-name admin --os-username admin --os-password ADMIN_PASS \
--os-auth-url http://controller:35357/v2.0 token-get
# +-----------+----------------------------------+
# |  Property |              Value               |
# +-----------+----------------------------------+
# |  expires  |       2015-02-08T05:27:04Z       |
# |     id    | b25eba9d23e74c0399886fa28fa662c5 |
# | tenant_id | 106f9551e8214b4e97d9c7a1fe935a81 |
# |  user_id  | 99ce47fd50be49cda908059b33f671b3 |
# +-----------+----------------------------------+

keystone --os-tenant-name admin --os-username admin --os-password ADMIN_PASS \
--os-auth-url http://controller:35357/v2.0 tenant-list
# +----------------------------------+---------+---------+
# |                id                |   name  | enabled |
# +----------------------------------+---------+---------+
# | 106f9551e8214b4e97d9c7a1fe935a81 |  admin  |   True  |
# | e639ec0f60084f36910a76cfcfe42e77 |   demo  |   True  |
# | bde34c68c83a4bcbbf89d16c4876ef2d |  rober  |   True  |
# | 3427d7d1a0f647b3bcdf65807ca1a898 | service |   True  |
# +----------------------------------+---------+---------+

keystone --os-tenant-name admin --os-username admin --os-password ADMIN_PASS \
--os-auth-url http://controller:35357/v2.0 user-list
# +----------------------------------+-------+---------+---------------+
# |                id                |  name | enabled |     email     |
# +----------------------------------+-------+---------+---------------+
# | 99ce47fd50be49cda908059b33f671b3 | admin |   True  | EMAIL_ADDRESS |
# | 95a57b849d32434ea8bf2ad4dc93de7e |  demo |   True  |  EMAIL_ADDRES |
# | 6036a39864b048aaa11fa102821f670b | rober |   True  | EMAIL_ADDRESS |
# +----------------------------------+-------+---------+---------------+

keystone --os-tenant-name admin --os-username admin --os-password ADMIN_PASS \
--os-auth-url http://controller:35357/v2.0 role-list
# +----------------------------------+----------+
# |                id                |   name   |
# +----------------------------------+----------+
# | 9fe2ff9ee4384b1894a90878d3e92bab | _member_ |
# | a384bf51990147c4bcb75e46af7d1d65 |  admin   |
# +----------------------------------+----------+

keystone --os-tenant-name demo --os-username demo --os-password DEMO_PASS \
--os-auth-url http://controller:35357/v2.0 token-get
# +-----------+----------------------------------+
# |  Property |              Value               |
# +-----------+----------------------------------+
# |  expires  |       2015-02-08T05:29:52Z       |
# |     id    | 0f43ec255bce4d13b38982724a67d57f |
# | tenant_id | e639ec0f60084f36910a76cfcfe42e77 |
# |  user_id  | 95a57b849d32434ea8bf2ad4dc93de7e |
# +-----------+----------------------------------+

keystone --os-tenant-name rober --os-username rober --os-password ROBER_PASS \
--os-auth-url http://controller:35357/v2.0 token-get
# +-----------+----------------------------------+
# |  Property |              Value               |
# +-----------+----------------------------------+
# |  expires  |       2015-02-08T05:30:23Z       |
# |     id    | 2111a2bdac09495f8f563437bd01045e |
# | tenant_id | bde34c68c83a4bcbbf89d16c4876ef2d |
# |  user_id  | 6036a39864b048aaa11fa102821f670b |
# +-----------+----------------------------------+

keystone --os-tenant-name demo --os-username demo --os-password DEMO_PASS \
--os-auth-url http://controller:35357/v2.0 user-list
# You are not authorized to perform the requested action: admin_required (HTTP 403)

# [INFO]
# Port 35357 is used for administrative functions only. 
# Port 5000 is for normal user functions and is the most commonly used.

## Add admin-openrc.sh and demo-openrc.sh
sudo cp -p admin-openrc.sh /opt/deploystack
sudo cp -p demo-openrc.sh /opt/deploystack

# -> controller/glance.sh