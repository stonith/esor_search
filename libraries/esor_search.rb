module Esor
  attr_accessor :instances

  def ec2
    require 'aws-sdk'

    Aws.config.update({
      region: node['ec2']['placement_availability_zone'].chop,
      credentials: Aws::SharedCredentials.new(
        region: node['ec2']['placement_availability_zone'].chop
      )
    })

    Chef::Log.debug('Initializing the EC2 Client')
    @ec2 ||= Aws::EC2::Client.new
  end

  def esor_results(tag_key=node['esor']['aws_tag_key'],tag_value=node['esor']['aws_tag_value'])

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

    node.run_state['esor'] = {}
    resp[:reservations].each do |reservation|
      reservation[:instances].each do |instance|
        tags = {}
        instance[:tags].each do | tag |
          tags[tag[:key]] = tag[:value]
        end
        node.run_state['esor'][instance[:instance_id]] = tags
      end
    end
    return node.run_state['esor']
  end

  def esor_search(tag_name,tag_value)
    esor_results unless node.run_state['esor']

    results = []
    node.run_state['esor'].each do | instance,tags |
      results << instance if tags[tag_name].match(tag_value)
    end
    return results
  end

  Chef::Recipe.send(:include, Esor)

end
