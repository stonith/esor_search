module Esor
  class Amazon
    attr_reader :node
    def initialize(obj)
      require 'aws-sdk'
      @node = obj
    end

    def ec2
      @ec2 ||= begin
        Chef::Log.debug('Initializing the EC2 Client')
        Aws.config.update({region: node['ec2']['placement_availability_zone'].chop})
        Aws::EC2::Client.new
      end
    end

    def search(tag_key=nil,tag_value=nil)
      tag_key = node['esor']['tag_key']
      tag_value = node['esor']['tag_value']

      resp = ec2.describe_instances({
        dry_run: false,
        filters: [
          {
            name: "tag:#{tag_key}",
            values: [tag_value]
          },
          {
            name: "instance-state-name",
            values: ["running"]
          }
        ],
      })

      instances = {}
      resp[:reservations].each do |reservation|
        reservation[:instances].each do |instance|
          tags = {}
          tags['private_dns_name'] = instance[:private_dns_name]
          tags['availability_zone'] = instance['placement']['availability_zone']
          instance[:tags].each do |tag|
            tags[tag[:key].downcase] = tag[:value]
          end
          instances[instance[:instance_id]] = tags
        end
      end
      return instances
    end

  end
end
