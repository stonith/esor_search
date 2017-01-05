module Esor

  include Esor::Amazon

  def esor_source
    case node['esor']['source']
    when 'aws'
      aws
    when 'gcloud'
      gcloud
    else
      Chef::Application.fatal!("An ESOR source must be specified. Valid sources are 'aws' or 'gcloud'.", 82)
    end
  end

  def esor_run_state
    node.run_state['esor'] = esor_source
  end

  def esor_search(tag_name,tag_value,return_tag = nil)
    esor_run_state unless node.run_state['esor']

    results = []
    node.run_state['esor'].each do | instance,tags |
      next unless tags[tag_name]
      if return_tag
        results << tags[return_tag] if tags[tag_name].match(tag_value)
      else
        results << instance if tags[tag_name].match(tag_value)
      end
    end
    return results.sort
  end

  Chef::Recipe.send(:include, Esor)

end
