# After you configure the Compute services, you can launch an instance. An instance is a
# virtual machine that OpenStack provisions on a Compute servers

# Generate a keypair that consists of a private and public key to be able to launch
# instances on OpenStack

ssh-keygen
cd .ssh

# If the error: ERROR: You must provide a username via either --os-username or env[OS_USERNAME]
# try to source openrc.sh (the credentials must to be imported!)

nova keypair-add --pub_key id_rsa.pub mykey

nova keypair-list
# +-------+-------------------------------------------------+
# | Name  | Fingerprint                                     |
# +-------+-------------------------------------------------+
# | mykey | 57:06:9c:82:c3:8c:4d:0b:5c:3e:1f:15:dd:3f:55:56 |
# +-------+-------------------------------------------------+

# To launch an instance, you must specify the ID for the flavor you want to use for the
# instance. A flavor is a resource allocation profile

nova flavor-list
# +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
# | ID | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
# +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
# | 1  | m1.tiny   | 512       | 1    | 0         |      | 1     | 1.0         | True      |
# | 2  | m1.small  | 2048      | 20   | 0         |      | 1     | 1.0         | True      |
# | 3  | m1.medium | 4096      | 40   | 0         |      | 2     | 1.0         | True      |
# | 4  | m1.large  | 8192      | 80   | 0         |      | 4     | 1.0         | True      |
# | 5  | m1.xlarge | 16384     | 160  | 0         |      | 8     | 1.0         | True      |
# +----+-----------+-----------+------+-----------+------+-------+-------------+-----------+

# Get the ID of the image to use for the instance

nova image-list
# +--------------------------------------+--------------+--------+--------+
# | ID                                   | Name         | Status | Server |
# +--------------------------------------+--------------+--------+--------+
# | f2e4d06b-0a0f-46b4-9204-374f7c7e8234 | CirrOS 0.3.1 | ACTIVE |        |
# +--------------------------------------+--------------+--------+--------+

# To use SSH and ping, you must configure security group rules

nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
# +-------------+-----------+---------+-----------+--------------+
# | IP Protocol | From Port | To Port | IP Range  | Source Group |
# +-------------+-----------+---------+-----------+--------------+
# | tcp         | 22        | 22      | 0.0.0.0/0 |              |
# +-------------+-----------+---------+-----------+--------------+

nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
# +-------------+-----------+---------+-----------+--------------+
# | IP Protocol | From Port | To Port | IP Range  | Source Group |
# +-------------+-----------+---------+-----------+--------------+
# | icmp        | -1        | -1      | 0.0.0.0/0 |              |
# +-------------+-----------+---------+-----------+--------------+

# Launch the instance:

# nova boot --flavor flavorType --key_name keypairName --
# image ID newInstanceName

nova boot --flavor 1 --key_name mykey --image f2e4d06b-0a0f-46b4-9204-374f7c7e8234 --security_group default cirrOS
# +--------------------------------------+-----------------------------------------------------+
# | Property                             | Value                                               |
# +--------------------------------------+-----------------------------------------------------+
# | OS-DCF:diskConfig                    | MANUAL                                              |
# | OS-EXT-AZ:availability_zone          | nova                                                |
# | OS-EXT-SRV-ATTR:host                 | -                                                   |
# | OS-EXT-SRV-ATTR:hypervisor_hostname  | -                                                   |
# | OS-EXT-SRV-ATTR:instance_name        | instance-00000001                                   |
# | OS-EXT-STS:power_state               | 0                                                   |
# | OS-EXT-STS:task_state                | scheduling                                          |
# | OS-EXT-STS:vm_state                  | building                                            |
# | OS-SRV-USG:launched_at               | -                                                   |
# | OS-SRV-USG:terminated_at             | -                                                   |
# | accessIPv4                           |                                                     |
# | accessIPv6                           |                                                     |
# | adminPass                            | poEyEwJz5k4F                                        |
# | config_drive                         |                                                     |
# | created                              | 2014-08-06T20:20:48Z                                |
# | flavor                               | m1.tiny (1)                                         |
# | hostId                               |                                                     |
# | id                                   | 3214069d-a1c5-4cb4-a1e1-9453364f8612                |
# | image                                | CirrOS 0.3.1 (f2e4d06b-0a0f-46b4-9204-374f7c7e8234) |
# | key_name                             | mykey                                               |
# | metadata                             | {}                                                  |
# | name                                 | cirrOS                                              |
# | os-extended-volumes:volumes_attached | []                                                  |
# | progress                             | 0                                                   |
# | security_groups                      | default                                             |
# | status                               | BUILD                                               |
# | tenant_id                            | 75a2f462a05a4819898121ecc62195b7                    |
# | updated                              | 2014-08-06T20:20:48Z                                |
# | user_id                              | 5a1f47f01a8d40d5a97149edf2c88168                    |
# +--------------------------------------+-----------------------------------------------------+

nova list

# +--------------------------------------+--------+--------+------------+-------------+----------+
# | ID                                   | Name   | Status | Task State | Power State | Networks |
# +--------------------------------------+--------+--------+------------+-------------+----------+
# | 3214069d-a1c5-4cb4-a1e1-9453364f8612 | cirrOS | BUILD  | spawning   | NOSTATE     |          |
# +--------------------------------------+--------+--------+------------+-------------+----------+

# THSOOT if the Status of the VM is ERROR: 

# Don't get the vmnet correct!!

# In controller

tail -f 20 /var/log/nova/scheduler.log 

nova-manage service list

nova net-list

nova net-delete

nova list

nova delete

# In compute

service openstack-nova-compute restart 

tail -f /var/log/nova/network.log

# libvirtError: internal error no supported architecture for os type 'hvm'\n"]

# Check the VT-x in the computer
sudo apt-get install cpu-checker
sudo kvm-ok

# As you are running OpenStack within a virtual machine you need to set this in /etc/nova/nova.conf 
# on your compute host(s) to use QEMU:

# libvirt_type=qemu

# Currently the compute host is trying to use KVM but the virtualization extensions KVM 
# requires are not available, because you are running in a virtual machine and nested virtualization 
# is not enabled/available.