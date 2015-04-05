
################################
# Chapter 13 LAUNCH_INSTANCE   #
################################
# Install the packages:
apt-get install -y openstack-dashboard apache2 libapache2-mod-wsgi \
memcached python-memcache

cp -p /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py.backup

# Edit /etc/openstack-dashboard/local_settings.py

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

# Optionally, configure the time zone:
# TIME_ZONE = "TIME_ZONE"

