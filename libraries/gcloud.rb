module Esor
  class Gcloud
    attr_reader :node
    def initialize(obj)
      require 'googleauth'
      require 'google/apis/compute_v1'
      @node = obj
    end

    def gce
      @gce ||= begin
        Chef::Log.debug('Initializing the Google API Client')
        g = Google::Apis::ComputeV1::ComputeService.new
        scopes =  ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/compute']
        g.authorization ||= Google::Auth.get_application_default(scopes)
        g
      end
    end

    def search

      resp = gce.list_instances(
        node['gce']['project']['projectId'],
        node['gce']['instance']['zone'].split('/').last,
        fields: 'items(id,metadata/items,name,networkInterfaces/networkIP,status,zone)'
      )

      instances = {}
      resp.items.each do |item|
        tags = {}
        tags['name'] = item.name
        tags['availability_zone'] = item.zone.split('/').last
        tags['private_ip'] = item.network_interfaces.first.network_ip
        item.metadata.items.each do | tag |
          next if tag.key == 'startup-script'
          tags[tag.key.downcase] = tag.value
        end
        instances[item.id] = tags
      end
      return instances
    end
  end
end
