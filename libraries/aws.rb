module Esor
  module Amazon

    def require_aws_sdk
      # require the version of the aws-sdk specified in the node attribute
      gem 'aws-sdk', node['aws']['aws_sdk_version']
      require 'aws-sdk'
      Chef::Log.debug("Node had aws-sdk #{node['aws']['aws_sdk_version']} installed. No need to install gem.")
    rescue LoadError
      Chef::Log.debug("Did not find aws-sdk version #{node['aws']['aws_sdk_version']} installed. Installing now")

      chef_gem 'aws-sdk' do
        version node['aws']['aws_sdk_version']
        compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
        action :install
      end

      require 'aws-sdk'
    end

    def ec2
      require_aws_sdk
      Aws.config.update({
        region: node['ec2']['placement_availability_zone'].chop,
        credentials: Aws::SharedCredentials.new(
          region: node['ec2']['placement_availability_zone'].chop
        )
      })

      Chef::Log.debug('Initializing the EC2 Client')
      @ec2 ||= Aws::EC2::Client.new
    end

    def aws(
      tag_key=node['esor']['tag_key'],
      tag_value=node['esor']['tag_value']
      )

      ec2

      resp = ec2.describe_instances({
        dry_run: false,
        filters: [
          {
            name: "tag:#{tag_key}",
            values: [tag_value],
          },
        ],
      })

      instances = {}
      resp[:reservations].each do |reservation|
        reservation[:instances].each do |instance|
          tags = {}
          instance[:tags].each do | tag |
            tags[tag[:key]] = tag[:value]
          end
          instances[instance[:instance_id]] = tags
        end
      end
      return instances
    end

  end
end
