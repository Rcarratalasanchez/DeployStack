#########################
# Chapter 4 PREINSTALL  #
#########################

echo "# controller
10.0.0.11 controller
# network
10.0.0.21 network
# compute1
10.0.0.31 compute1" > /etc/hosts

apt-get install -y ubuntu-cloud-keyring
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
"trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list

apt-get update && apt-get -y dist-upgrade

apt-get install -y ntp
service ntp restart
ntpq -c peers
