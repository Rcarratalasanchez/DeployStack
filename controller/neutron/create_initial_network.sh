################################
# Chapter 12 INITIAL_NETWORKS  #
################################

## External network

# Source the admin credentials to gain access to admin-only CLI commands:
source admin-openrc.sh

# Create the network:
neutron net-create ext-net --router:external True \
--provider:physical_network external --provider:network_type flat

# Created a new network:
# +---------------------------+--------------------------------------+
# | Field                     | Value                                |
# +---------------------------+--------------------------------------+
# | admin_state_up            | True                                 |
# | id                        | cfcd12df-117a-4cef-9b8d-b257503fab5b |
# | name                      | ext-net                              |
# | provider:network_type     | flat                                 |
# | provider:physical_network | external                             |
# | provider:segmentation_id  |                                      |
# | router:external           | True                                 |
# | shared                    | False                                |
# | status                    | ACTIVE                               |
# | subnets                   |                                      |
# | tenant_id                 | c5a55a9e2a184b01865257d1157fe0e2     |
# +---------------------------+--------------------------------------+

# NOTE: Replace FLOATING_IP_START and FLOATING_IP_END with the first and last IP
# addresses of the range that you want to allocate for floating IP addresses. Replace
# EXTERNAL_NETWORK_CIDR with the subnet associated with the physical network. Re-
# place EXTERNAL_NETWORK_GATEWAY with the gateway associated with the physical
# network, typically the ".1" IP address. You should disable DHCP on this subnet because
# instances do not connect directly to the external network and floating IP addresses re-
# quire manual assignment.


# To create a subnet on the external network

# Create the subnet:
neutron subnet-create ext-net --name ext-subnet \
--allocation-pool start=192.168.1.101,end=192.168.1.200 \
--disable-dhcp --gateway 192.168.1.1 192.168.1.0/24

# Created a new subnet:
# +-------------------+----------------------------------------------------+
# | Field             | Value                                              |
# +-------------------+----------------------------------------------------+
# | allocation_pools  | {"start": "192.168.1.101", "end": "192.168.1.200"} |
# | cidr              | 192.168.1.0/24                                     |
# | dns_nameservers   |                                                    |
# | enable_dhcp       | False                                              |
# | gateway_ip        | 192.168.1.1                                        |
# | host_routes       |                                                    |
# | id                | b7140763-2ec4-4044-8349-720c92b306a8               |
# | ip_version        | 4                                                  |
# | ipv6_address_mode |                                                    |
# | ipv6_ra_mode      |                                                    |
# | name              | ext-subnet                                         |
# | network_id        | cfcd12df-117a-4cef-9b8d-b257503fab5b               |
# | tenant_id         | c5a55a9e2a184b01865257d1157fe0e2                   |
# +-------------------+----------------------------------------------------+

## Tenant network

# To create the tenant network

source demo-openrc.sh

# Create the network:
neutron net-create demo-net

# Created a new network:
# +-----------------+--------------------------------------+
# | Field           | Value                                |
# +-----------------+--------------------------------------+
# | admin_state_up  | True                                 |
# | id              | 5e4bb236-1abf-43c6-92a8-17881b7d5f61 |
# | name            | demo-net                             |
# | router:external | False                                |
# | shared          | False                                |
# | status          | ACTIVE                               |
# | subnets         |                                      |
# | tenant_id       | 0cb79c995a744b97941b3597aa595046     |
# +-----------------+--------------------------------------+

# Create the subnet:

# $ neutron subnet-create demo-net --name demo-subnet \
# --gateway TENANT_NETWORK_GATEWAY TENANT_NETWORK_CIDR

# Replace TENANT_NETWORK_CIDR with the subnet you want to associate with the ten-
# ant network and TENANT_NETWORK_GATEWAY with the gateway you want to asso-
# ciate with it, typically the ".1" IP address.

neutron subnet-create demo-net --name demo-subnet \
--gateway 192.168.3.1 192.168.3.0/24

# Created a new subnet:
# +-------------------+--------------------------------------------------+
# | Field             | Value                                            |
# +-------------------+--------------------------------------------------+
# | allocation_pools  | {"start": "192.168.3.2", "end": "192.168.3.254"} |
# | cidr              | 192.168.3.0/24                                   |
# | dns_nameservers   |                                                  |
# | enable_dhcp       | True                                             |
# | gateway_ip        | 192.168.3.1                                      |
# | host_routes       |                                                  |
# | id                | 79918035-6b46-4590-bf85-53ede9939d2d             |
# | ip_version        | 4                                                |
# | ipv6_address_mode |                                                  |
# | ipv6_ra_mode      |                                                  |
# | name              | demo-subnet                                      |
# | network_id        | 5e4bb236-1abf-43c6-92a8-17881b7d5f61             |
# | tenant_id         | 0cb79c995a744b97941b3597aa595046                 |
# +-------------------+--------------------------------------------------+

# To create a router on the tenant network and attach the external and tenant
# networks to it

# Create the router:
neutron router-create demo-router

# Created a new router:
# +-----------------------+--------------------------------------+
# | Field                 | Value                                |
# +-----------------------+--------------------------------------+
# | admin_state_up        | True                                 |
# | external_gateway_info |                                      |
# | id                    | 6bf3437c-bd8d-4443-8707-3c3f3f982832 |
# | name                  | demo-router                          |
# | routes                |                                      |
# | status                | ACTIVE                               |
# | tenant_id             | 0cb79c995a744b97941b3597aa595046     |
# +-----------------------+--------------------------------------+

# Attach the router to the demo tenant subnet:
neutron router-interface-add demo-router demo-subnet
# Added interface 85641620-c9be-42fc-a62b-91d3381736de to router demo-router.

# Attach the router to the external network by setting it as the gateway:
neutron router-gateway-set demo-router ext-net
# Set gateway for router demo-router

# --> Go to chapter 13 controller/post/launch_instance.sh