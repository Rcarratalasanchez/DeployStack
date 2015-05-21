#######################
# Chapter 14 HORIZON  #
#######################

apt-get -y install openstack-dashboard apache2 libapache2-mod-wsgi \
memcached python-memcache

cp -p /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py.backup

cp -p local_settings.py /etc/openstack-dashboard/local_settings.py

# Edit the /etc/openstack-dashboard/local_settings.py file and complete
# the following actions:

# Configure the dashboard to use OpenStack services on the controller node:
# OPENSTACK_HOST = "controller"

# Allow all hosts to access the dashboard:
# ALLOWED_HOSTS = ['*']

# Configure the memcached session storage service:
# CACHES = {
# 'default': {
# 'BACKEND': 'django.core.cache.backends.memcached.
# MemcachedCache',
# 'LOCATION': '127.0.0.1:11211',
# }
# }

# Restart the web server and session storage service:
service apache2 restart
service memcached restart