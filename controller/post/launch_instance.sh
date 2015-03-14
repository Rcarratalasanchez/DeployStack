################################
# Chapter 13 LAUNCH_INSTANCE   #
################################

# To generate a key pair

# Source the demo tenant credentials:
source demo-openrc.sh

# Generate a key pair:
ssh-keygen

# Add the public key to your OpenStack environment:
nova keypair-add --pub-key ~/.ssh/id_rsa.pub demo-key

# Verify addition of the public key:
nova keypair-list
# +----------+-------------------------------------------------+
# | Name     | Fingerprint                                     |
# +----------+-------------------------------------------------+
# | demo-key | 46:b4:f8:c9:39:31:25:48:38:37:b4:73:56:c1:68:1d |
# +----------+-------------------------------------------------+

# List the availaible flavours
nova flavor-list

# Tiny flavour with 1 ID
# +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
# | ID | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
# +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
# | 1  | m1.tiny   | 512       | 1    | 0         |      | 1     | 1.0         | True      |
# | 2  | m1.small  | 2048      | 20   | 0         |      | 1     | 1.0         | True      |
# | 3  | m1.medium | 4096      | 40   | 0         |      | 2     | 1.0         | True      |
# | 4  | m1.large  | 8192      | 80   | 0         |      | 4     | 1.0         | True      |
# | 5  | m1.xlarge | 16384     | 160  | 0         |      | 8     | 1.0         | True      |
# +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+

# List of images 
nova image-list
# +--------------------------------------+---------------------+--------+--------+
# | ID                                   | Name                | Status | Server |
# +--------------------------------------+---------------------+--------+--------+
# | 3aecac8a-6074-41de-a6d5-4fecf0a856e3 | cirros-0.3.3-x86_64 | ACTIVE |        |
# | c56c5b39-c81d-4746-9e2e-dd495bd90199 | trusty-image        | ACTIVE |        |
# +--------------------------------------+---------------------+--------+--------+

# List available networks:
neutron net-list
# +--------------------------------------+----------+-----------------------------------------------------+
# | id                                   | name     | subnets                                             |
# +--------------------------------------+----------+-----------------------------------------------------+
# | cfcd12df-117a-4cef-9b8d-b257503fab5b | ext-net  | b7140763-2ec4-4044-8349-720c92b306a8                |
# | 5e4bb236-1abf-43c6-92a8-17881b7d5f61 | demo-net | 79918035-6b46-4590-bf85-53ede9939d2d 192.168.3.0/24 |
# +--------------------------------------+----------+-----------------------------------------------------+

List available security groups:
$ nova secgroup-list
# +--------------------------------------+---------+-------------+
# | Id                                   | Name    | Description |
# +--------------------------------------+---------+-------------+
# | ee7b3e4d-2ea5-4969-b463-7b44afeffd0e | default | default     |
# +--------------------------------------+---------+-------------+

nova boot --flavor m1.tiny --image cirros-0.3.3-x86_64 --nic net-id=5e4bb236-1abf-43c6-92a8-17881b7d5f61 \
--security-group default --key-name demo-key demo-instance1
# +--------------------------------------+------------------------------------------------------------+
# | Property                             | Value                                                      |
# +--------------------------------------+------------------------------------------------------------+
# | OS-DCF:diskConfig                    | MANUAL                                                     |
# | OS-EXT-AZ:availability_zone          | nova                                                       |
# | OS-EXT-STS:power_state               | 0                                                          |
# | OS-EXT-STS:task_state                | scheduling                                                 |
# | OS-EXT-STS:vm_state                  | building                                                   |
# | OS-SRV-USG:launched_at               | -                                                          |
# | OS-SRV-USG:terminated_at             | -                                                          |
# | accessIPv4                           |                                                            |
# | accessIPv6                           |                                                            |
# | adminPass                            | ag2Rhc4kYv58                                               |
# | config_drive                         |                                                            |
# | created                              | 2015-03-14T16:35:17Z                                       |
# | flavor                               | m1.tiny (1)                                                |
# | hostId                               |                                                            |
# | id                                   | e6b2ac6a-11ab-4943-9801-9f07a05cf9d1                       |
# | image                                | cirros-0.3.3-x86_64 (3aecac8a-6074-41de-a6d5-4fecf0a856e3) |
# | key_name                             | demo-key                                                   |
# | metadata                             | {}                                                         |
# | name                                 | demo-instance1                                             |
# | os-extended-volumes:volumes_attached | []                                                         |
# | progress                             | 0                                                          |
# | security_groups                      | default                                                    |
# | status                               | BUILD                                                      |
# | tenant_id                            | 0cb79c995a744b97941b3597aa595046                           |
# | updated                              | 2015-03-14T16:35:17Z                                       |
# | user_id                              | bb5a894ef5ea4325a721e67a72b866dd                           |
# +--------------------------------------+------------------------------------------------------------+

nova get-vnc-console demo-instance18 novnc
# +-------+---------------------------------------------------------------------------------+
# | Type  | Url                                                                             |
# +-------+---------------------------------------------------------------------------------+
# | novnc | http://controller:6080/vnc_auto.html?token=737ea270-b6da-4944-8478-e0bb9e482825 |
# +-------+---------------------------------------------------------------------------------+


nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
# +-------------+-----------+---------+-----------+--------------+
# | IP Protocol | From Port | To Port | IP Range  | Source Group |
# +-------------+-----------+---------+-----------+--------------+
# | icmp        | -1        | -1      | 0.0.0.0/0 |              |
# +-------------+-----------+---------+-----------+--------------+

nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
# +-------------+-----------+---------+-----------+--------------+
# | IP Protocol | From Port | To Port | IP Range  | Source Group |
# +-------------+-----------+---------+-----------+--------------+
# | tcp         | 22        | 22      | 0.0.0.0/0 |              |
# +-------------+-----------+---------+-----------+--------------+

neutron floatingip-create ext-net
# Created a new floatingip:
# +---------------------+--------------------------------------+
# | Field               | Value                                |
# +---------------------+--------------------------------------+
# | fixed_ip_address    |                                      |
# | floating_ip_address | 192.168.1.102                        |
# | floating_network_id | cfcd12df-117a-4cef-9b8d-b257503fab5b |
# | id                  | a658c81f-ebdf-4eab-80c1-26727b687de3 |
# | port_id             |                                      |
# | router_id           |                                      |
# | status              | DOWN                                 |
# | tenant_id           | 0cb79c995a744b97941b3597aa595046     |
# +---------------------+--------------------------------------+

nova floating-ip-associate demo-instance1 192.168.1.102