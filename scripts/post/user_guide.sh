## User Guide

# Create a project (tenant):

keystone tenant-create --name ciscoteam --description 'este es el ciscoteam tenant'

# +-------------+----------------------------------+
# |   Property  |              Value               |
# +-------------+----------------------------------+
# | description |   este es el ciscoteam tenant    |
# |   enabled   |               True               |
# |      id     | eb8427ae3e0c4070922a127cc7bc542e |
# |     name    |            ciscoteam             |
# +-------------+----------------------------------+

# Create a user:

keystone user-list

# +----------------------------------+--------+---------+--------------------+
# |                id                |  name  | enabled |       email        |
# +----------------------------------+--------+---------+--------------------+
# | 125c892824d1480e80093f04f007ffea | admin  |   True  | admin@example.com  |
# | 64ef7c163f60481b967d545d6e915b72 | glance |   True  | glance@example.com |
# | dfb5b436721149f4bf1fb6c452eed425 |  nova  |   True  |  nova@example.com  |
# | 608d18041a5d4b4081425d30be283da1 | rober  |   True  |     kk@kk.com      |
# +----------------------------------+--------+---------+--------------------+

# To create the user:

keystone user-create --name jota --tenant_id eb8427ae3e0c4070922a127cc7bc542e --pass jotapass

# +----------+----------------------------------+
# | Property |              Value               |
# +----------+----------------------------------+
# |  email   |                                  |
# | enabled  |               True               |
# |    id    | 9cedb349d9d84dee8ff684e88c21a911 |
# |   name   |               jota               |
# | tenantId | eb8427ae3e0c4070922a127cc7bc542e |
# +----------+----------------------------------+

# Create and assing a role

keystone role-list

# +----------------------------------+----------+
# |                id                |   name   |
# +----------------------------------+----------+
# | 9fe2ff9ee4384b1894a90878d3e92bab | _member_ |
# | 0b08ea1611664ffc8c71d237c0105fd8 |  admin   |
# +----------------------------------+----------+

keystone role-create --name tester

+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|    id    | 1057970295a4490ea4bdc9681f089285 |
|   name   |              tester              |
+----------+----------------------------------+

# To assign a user to a project, you must assign the role to a user-project pair. To do this, you need the user, role, and project IDs.

# keystone user-role-add --user USER_ID --role ROLE_ID --tenant TENANT_ID

keystone user-role-add --user 9cedb349d9d84dee8ff684e88c21a911 --role 9fe2ff9ee4384b1894a90878d3e92bab --tenant eb8427ae3e0c4070922a127cc7bc542e

# To verify the role assignment:

keystone user-role-list --user USER_ID --tenant TENANT_ID

# To get details for a specified role:

keystone role-get ROLE_ID

