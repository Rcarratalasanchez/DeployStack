#!/bin/bash

function restart_controller(){

	service mysql restart
	service ntp restart
	service rabbitmq-server restart

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

# TSHOOT:

neutron agent-list
nova service-list  
nova-manage service list

# TSHOOT2:

 # ERROR oslo.messaging.rpc.dispatcher [-] Exception during message handling: Endpoint does not support RPC version 3.33

 # Solved because Found out I had not added the juno repo on the compute node, silly me.
 # Add the juno repo and updagre and dist-upgrade -> restart all services

 # TSHOOT 3:

# {"message": "No valid host was found. ", "code": 500, "created": "2015-03-14T20:34:25Z"} |
# When launch the 2º instance the VM exit with 500 code

# "No valid host" is an error from Nova, not from Heat. It indicates that Nova was unable to find a suitable hypervisor 
# on which to schedule your instance. This can mean that (a) you are requesting more resources (memory, disk, etc) 
# than are currently available, or (b) that there is a configuration problem with Nova preventing it from seeing any available hypervisors.