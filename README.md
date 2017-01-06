External System of Record Search cookbook
=========================================

In many situations an external SoR (system of record or single source of truth) is preferred over using chef server searches. For example, an external source like Consul, Zookeeper, or AWS is often the source of "service discovery". This cookbook provides a generic library to perform global searches against an external SoR. The initial search uses the `default['esor']['tag_value']` and `default['esor']['tag_value']` attributes to provide a global search result stored in `node.run_state` after which subsequent searches merely filter from these results. This allows for a single request against the external SoR for each chef run. Note that every source has a different equivalent term to a "tag" ie. GCE uses labels.

### Platforms
Currently developed on Ubuntu 14.04 but should work on all platforms.

### Supported Sources

AWS Only

TODO: GCE, Zookeeper, Consul, etc

Attributes
----------

The following attributes are used:

* `node['aws']['aws_sdk_version']` - AWS SDK version
* `default['esor']['tag_key']` - global search key
* `default['esor']['tag_value']` - global search value
* `default['esor']['source']` - source to use ie. aws, consul, etc

Usage
-----

Include the `default` recipe close to the beginning of the run_list. When you call `esor_search`, pass the "tag key" and "tag value" to the to filter the results required. The example below:

```ruby
esor_search('Name','app')
```

The above example will return all instance id's for which the tag key of "Name" has a tag value that contains "app".

A `return_tag` can also be specified if you want a list of a specific tag returned:

```ruby
esor_search('Name','app','Name')
```

The above examples will return the value of the 'Name' tag as an array.

### Sources

##### AWS
The AWS source uses the ruby aws-sdk gem and assumes that a .aws/credentials file exists and follows the SharedCredentials syntax. The easiest way to implement this however is to use AWS IAM Instance Roles with an attached policy with the `ec2:DescribeInstances` IAM permission.
NOTE: `private_dns_name` and `availability_zone` are not AWS tags but has been added as an "esor" tag to be used

##### TODO
* add more sources like GCE, Zookeeper, Consul, etc
* ability to specify what data is returned or stored. Currently only instance ids and tags are returned.
* add tests

Authors
-----------------
- Author:: Darren Foo (<stonith@users.noreply.github.com>)
