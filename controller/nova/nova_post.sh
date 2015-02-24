#############################
# Chapter 6 VERIFY_COMPUTE  #
#############################

source admin-openrc.sh

# List service components to verify successful launch of each process:

nova service-list
# +----+------------------+------------+----------+---------+-------+----------------------------+-----------------+
# | Id | Binary           | Host       | Zone     | Status  | State | Updated_at                 | Disabled Reason |
# +----+------------------+------------+----------+---------+-------+----------------------------+-----------------+
# | 1  | nova-cert        | controller | internal | enabled | up    | 2015-02-24T19:15:56.000000 | -               |
# | 2  | nova-consoleauth | controller | internal | enabled | up    | 2015-02-24T19:15:56.000000 | -               |
# | 3  | nova-scheduler   | controller | internal | enabled | up    | 2015-02-24T19:15:56.000000 | -               |
# | 4  | nova-conductor   | controller | internal | enabled | up    | 2015-02-24T19:15:56.000000 | -               |
# | 5  | nova-compute     | compute    | nova     | enabled | up    | 2015-02-24T19:15:58.000000 | -               |
# +----+------------------+------------+----------+---------+-------+----------------------------+-----------------+

# List images in the Image Service catalog to verify connectivity with the Identity service and Image Service:

nova image-list
# +--------------------------------------+---------------------+--------+--------+
# | ID                                   | Name                | Status | Server |
# +--------------------------------------+---------------------+--------+--------+
# | 3aecac8a-6074-41de-a6d5-4fecf0a856e3 | cirros-0.3.3-x86_64 | ACTIVE |        |
# | c56c5b39-c81d-4746-9e2e-dd495bd90199 | trusty-image        | ACTIVE |        |
# +--------------------------------------+---------------------+--------+--------+

