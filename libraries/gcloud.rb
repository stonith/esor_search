module Esor
  module Gcloud

    def require_gcloud_sdk
      # require the version of the aws-sdk specified in the node attribute
      gem 'google-api-client', node['gcloud']['gcloud_sdk_version']
      require 'google-api-client'
      Chef::Log.debug("Node had google-api-client #{node['gcloud']['gcloud_sdk_version']} installed. No need to install gem.")
    rescue LoadError
      Chef::Log.debug("Did not find google-api-client version #{node['gcloud']['gcloud_sdk_version']} installed. Installing now")

      chef_gem 'google-api-client' do
        version node['gcloud']['gcloud_sdk_version']
        compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
        action :install
      end

      require 'googleauth'
      require 'google/apis/compute_v1'
    end

    def gce
      require_gcloud_sdk
      Chef::Log.debug('Initializing the Google API Client')
      @gce ||= Google::Apis::ComputeV1::ComputeService.new
      scopes =  ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/compute']
      @gce.authorization ||= Google::Auth.get_application_default(scopes)
    end

    def gcloud

      gce

      resp = @gce.list_instances(
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
