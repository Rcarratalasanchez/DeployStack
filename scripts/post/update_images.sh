### Upload Ubuntu Cloud Images

wget http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img

glance image-create --name precise-x86_64 --is-public True --disk-format qcow2 --container-format bare \
 --file precise-server-cloudimg-amd64-disk1.img --progress

# +------------------+--------------------------------------+
# | Property         | Value                                |
# +------------------+--------------------------------------+
# | checksum         | 60934df9d318707e05d57c655362605c     |
# | container_format | bare                                 |
# | created_at       | 2014-08-09T13:26:10                  |
# | deleted          | False                                |
# | deleted_at       | None                                 |
# | disk_format      | qcow2                                |
# | id               | c71db7cc-691b-438e-bd5f-462577bd6415 |
# | is_public        | True                                 |
# | min_disk         | 0                                    |
# | min_ram          | 0                                    |
# | name             | precise-x86_64                       |
# | owner            | b82272c59f6a4b109c62b0cb2344f377     |
# | protected        | False                                |
# | size             | 261095936                            |
# | status           | active                               |
# | updated_at       | 2014-08-09T13:26:11                  |
# +------------------+--------------------------------------+

# Be careful with the flavour because with flavour 1 (512 Mb , 1Gb disk) is not enough space for 
# Ubuntu image! Set another flavour with more space!

nova boot --flavor 2 --key_name mykey \
--image c71db7cc-691b-438e-bd5f-462577bd6415 --security_group default ubuntu

# For connect to the instance, you must to create a pem key and connect with

chmod 0600 yourPrivateKey.pem
ssh -i MyKey.pem ubuntu@10.0.0.2

# TSHOOT: Openstack does not free fixed IPs when instances are removed

# update fixed_ips set instance_id = NULL where reserved = false and allocated = false and leased = false and instance_id is not NULL;

# BugFix: killall dnsmasq; service nova-network restart

### Fedora Cloud Images:

wget http://download.fedoraproject.org/pub/fedora/linux/releases/19/Images/x86_64/Fedora-x86_64-19-20130627-sda.qcow2

glance image-create --name Fedora --is-public True --disk-format qcow2 --container-format bare \
 --file Fedora-x86_64-19-20130627-sda.qcow2 --progress