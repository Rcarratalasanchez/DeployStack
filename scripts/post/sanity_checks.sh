# This script checks the different services that are running in 

function restart_controller(){

	service ntpd restart
	service mysqld restart
	service qpidd restart

	service openstack-keystone restart

	service openstack-glance-api restart
	service openstack-glance-registry restart

	service openstack-nova-api restart
	service openstack-nova-cert restart
	service openstack-nova-consoleauth restart
	service openstack-nova-scheduler restart
	service openstack-nova-conductor restart
	service openstack-nova-novncproxy restart
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

