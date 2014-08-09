##### Horizon

yum install -y memcached python-memcached mod_wsgi openstack-dashboard

# Modify the value of CACHES['default']['LOCATION'] in /etc/openstack-
# dashboard/local_settings to match the ones set in /etc/sysconfig/ memcached

# Open /etc/openstack-dashboard/local_settings and look for this line:
# CACHES = {
# 'default': {
# 'BACKEND' : 'django.core.cache.backends.memcached.MemcachedCache',
# 'LOCATION' : '127.0.0.1:11211'
# }
# }

# Update the ALLOWED_HOSTS in local_settings.py to include the addresses you
# wish to access the dashboard from

# Edit /etc/openstack-dashboard/local_settings:

# ALLOWED_HOSTS = ['localhost', 'my-desktop', '192.168.0.10']

# Edit /etc/openstack-dashboard/local_settings and change
# OPENSTACK_HOST to the hostname of your Identity Service:

# OPENSTACK_HOST = "controller"

service httpd start
service memcached start
chkconfig httpd on
chkconfig memcached on

#TSHOOT: 

# Error: Directory index forbidden by Options directive: /var/www/html/

# In /etc/httpd/conf/httpd.conf add Options +Indexes

# Options +Indexes
# Order allow,deny
# Allow from all

# UPDATE!: there is a welcome.conf file that contains a Options -Indexes <--! Disabled this!

# Error: SuspiciousOperation: Invalid HTTP_HOST header (you may need to set ALLOWED_HOSTS): 192.168.0.10

# Add into /etc/openstack-dashboard/local_settings the IP from controller (192.168.0.10)

# ALLOWED_HOSTS = ['localhost', 'my-desktop', '192.168.0.10']

