# This script checks the different services that are running in 

function start_controller(){

	service ntpd start
	service mysqld start
	service qpidd start

	service openstack-keystone start

	service openstack-glance-api start
	service openstack-glance-registry start

	service openstack-nova-api start
	service openstack-nova-cert start
	service openstack-nova-consoleauth start
	service openstack-nova-scheduler start
	service openstack-nova-conductor start
	service openstack-nova-novncproxy start
}

function status_controller(){

	service ntpd status
	service mysqld status
	service qpidd status

	service openstack-keystone status

	service openstack-glance-api status
	service openstack-glance-registry status

	service openstack-nova-api status
	service openstack-nova-cert status
	service openstack-nova-consoleauth status
	service openstack-nova-scheduler status
	service openstack-nova-conductor status
	service openstack-nova-novncproxy status
}

