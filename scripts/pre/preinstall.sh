# Pre-install configurations 

# Networking

config_pre = "../../config/pre"

sudo cp $config_pre/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth1
sudo cp $config_pre/ifcfg-eth1 /etc/sysconfig/network-scripts/ifcfg-eth2

service network restart

# Hosts

hostname controller

sudo cp $config_pre/hosts /etc/hosts

# NTP

yum install ntp
service ntpd start
chkconfig ntpd on

# MySQL

yum install -y mysql mysql-server MySQL-python

cp /etc/my.cnf /etc/my.cnf.backup

MYSQL_HOST="192.168.0.10"
sudo sed -i "s/^bind\-address.*/bind-address = ${MYSQL_HOST}/g" /etc/my.cnf

service mysqld start
chkconfig mysqld on

mysql_install_db
/usr/bin/mysqladmin -u root password openstack
mysql_secure_installation

# OpenStack packages

# To enable the RDO repository, download and install the rdo-release-havana package
yum install -y http://repos.fedorapeople.org/repos/openstack/openstack-havana/rdo-release-havana-7.noarch.rpm

# Install the latest epel-release package
yum install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

# Install openstack-utils. This verifies that you can access the RDO repository
yum install openstack-utils


# The openstack-selinux package includes the policy files that are required to configure
# SELinux during OpenStack installation. Install openstack-selinux
yum install openstack-selinux

yum upgrade

reboot

# Messaging server

yum install -y qpid-cpp-server memcached

cp /etc/qpidd.conf /etc/qpidd.conf.backup
sudo sed -i "s/^auth=yes.*/auth=no/g" /etc/qpidd.conf

service qpidd start
chkconfig qpidd on

# -> Next step: keystone.sh