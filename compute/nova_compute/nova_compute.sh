#############################
# Chapter 5 CONFIG_COMPUTE  #
#############################

# Install packages
apt-get -y install nova-compute sysfsutils

cp -p /etc/nova/nova.conf /etc/nova/nova.conf.backup
cp -p /etc/nova/nova-compute.conf /etc/nova/nova-compute.conf.backup

cp -p nova.conf /etc/nova/nova.conf
cp -p nova-compute.conf /etc/nova/nova-compute.conf

# Edit the nova.conf with this parameters:

# In the [DEFAULT] section, configure RabbitMQ message broker access:
# [DEFAULT]
# ...
# rpc_backend = rabbit
# rabbit_host = controller
# rabbit_password = RABBIT_PASS

# In the [DEFAULT] and [keystone_authtoken] sections, configure Identity
# service access:
# [DEFAULT]
# ...
# auth_strategy = keystone
# [keystone_authtoken]
# ...
# auth_uri = http://controller:5000/v2.0
# identity_uri = http://controller:35357
# admin_tenant_name = service
# admin_user = nova
# admin_password = NOVA_PASS

# In the [DEFAULT] section, configure the my_ip option:
# [DEFAULT]
# ...
# my_ip = MANAGEMENT_INTERFACE_IP_ADDRESS
# Replace MANAGEMENT_INTERFACE_IP_ADDRESS with the IP address of the
# management network interface on your compute node, typically 10.0.0.31

# [DEFAULT]
# ...
# vnc_enabled = True
# vncserver_listen = 0.0.0.0
# vncserver_proxyclient_address = MANAGEMENT_INTERFACE_IP_ADDRESS
# novncproxy_base_url = http://controller:6080/vnc_auto.html

# [glance]
# ...
# host = controller

# Edit the [libvirt] section in the /etc/nova/nova-compute.conf file as follows

# [libvirt]
# ...
# virt_type = qemu

# Restart the compute service
service nova-compute restart

rm -f /var/lib/nova/nova.sqlite

# -> Go to Controller/nova/nova_post.sh