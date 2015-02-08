## PREINSTALL

# Network

yum install net-tools

service NetworkManager stop
service network start
chkconfig NetworkManager off
chkconfig network on

service firewalld stop
service iptables start
chkconfig firewalld off
chkconfig iptables on

## DNS

