### PREINSTALL

## Network

echo "# controller
10.0.0.11 controller
# network
10.0.0.21 network
# compute1
10.0.0.31 compute1" >> /etc/hosts

## NTP
apt-get -y install ntp
ntpq -c peers

## Openstack Packages
apt-get install ubuntu-cloud-keyring
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
"trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list

apt-get update && apt-get -y dist-upgrade

## Database
apt-get -y install mariadb-server python-mysqldb

# WARNING: Mariadb ask for the password in interactive mode -> Use:
#[ALTERNATIVE]
# export MYSQL_ROOT_PASS=openstack
# echo "mysql-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PASS" | sudo debconf-set-selections

sudo sed -i "s/^bind\-address.*/bind-address = 10.0.0.11/g" /etc/mysql/my.cnf
sudo sed -i "s/^#max_connections.*/max_connections = 512/g" /etc/mysql/my.cnf

# In the [mysqld] section, set the following keys to enable useful options and the
# UTF-8 character set:
# [mysqld]
# ...
# default-storage-engine = innodb
# innodb_file_per_table
# collation-server = utf8_general_ci
# init-connect = 'SET NAMES utf8'
# character-set-server = utf8

service mysql restart

mysql_secure_installation
# WARNING: in mysql_secure_installation ask in interactive mode of root Pass
# Ensure root can do its job
# [ALTERNATIVE]
# mysql -u root -p${MYSQL_ROOT_PASS} -h localhost -e "GRANT ALL ON *.* to root@\"localhost\" IDENTIFIED BY \"${MYSQL_ROOT_PASS}\" WITH GRANT OPTION;"
# mysql -u root -p${MYSQL_ROOT_PASS} -h localhost -e "GRANT ALL ON *.* to root@\"${MYSQL_HOST}\" IDENTIFIED BY \"${MYSQL_ROOT_PASS}\" WITH GRANT OPTION;"
# mysql -u root -p${MYSQL_ROOT_PASS} -h localhost -e "GRANT ALL ON *.* to root@\"%\" IDENTIFIED BY \"${MYSQL_ROOT_PASS}\" WITH GRANT OPTION;"
# mysqladmin -uroot -p${MYSQL_ROOT_PASS} flush-privileges


## Messaging Server
apt-get install -y rabbitmq-server

