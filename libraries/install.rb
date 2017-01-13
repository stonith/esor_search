module Esor
  module Install
    def gcloud
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

    def amazon
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
    end
  end
end