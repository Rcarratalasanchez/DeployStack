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


# #### IMPORTANT!!
# The external interface uses a special configuration without an IP address assigned to it.
# Configure the third interface as the external interface:
# Replace INTERFACE_NAME with the actual interface name. For example, eth2 or ens256.

# # The external network interface
# auto INTERFACE_NAME
# iface INTERFACE_NAME inet manual
# up ip link set dev $IFACE up
# down ip link set dev $IFACE down

# reboot