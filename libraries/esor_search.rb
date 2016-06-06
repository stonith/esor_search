module Esor

  # attr_accessor :instances
  include Esor::Amazon

  def esor_source
    aws if node['esor']['source'] == aws
  end

  def esor_run_state
    node.run_state['esor'] = esor_source
  end

  def esor_search(tag_name,tag_value)
    esor_run_state unless node.run_state['esor']

    results = []
    node.run_state['esor'].each do | instance,tags |
      results << instance if tags[tag_name].match(tag_value)
    end
    return results
  end

  Chef::Recipe.send(:include, Esor)

end
