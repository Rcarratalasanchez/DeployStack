
function restart_compute(){

	service ntp restart
	service rabbitmq-server restart
	service nova-compute restart

}