#!/bin/bash

function restart_controller(){

	service mysql restart
	service ntp restart
	service rabbitmq-server

	service keystone restart

	service glance-registry restart
	service glance-api restart

	service nova-api restart
	service nova-cert restart
	service nova-consoleauth restart
	service nova-scheduler restart
	service nova-conductor restart
	service nova-novncproxy restart

	service neutron-server restart
	
}
