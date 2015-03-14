
function restart_compute(){

	service ntp restart
	service nova-compute restart
	service openvswitch-switch restart
	service neutron-plugin-openvswitch-agent restart
	
}