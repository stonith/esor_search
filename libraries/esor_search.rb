require_relative './install'

module Esor
  include Esor::Install
  def esor_source
    send(node['esor']['source'])
    source = node['esor']['source'].dup
    source[0] = source[0].capitalize
    global = Esor.const_get(source).new(node)
    global.search
  rescue TypeError, NameError => e
      Chef::Application.fatal!("#{e} An ESOR source must be specified. Valid sources are 'amazon' or 'gcloud'.", 82)
  end

  def esor_run_state
    node.run_state['esor'] = esor_source
  end

  def esor_search(tag_name,tag_value,return_tag = nil)
    esor_run_state unless node.run_state['esor']

    results = []
    node.run_state['esor'].each do | instance,tags |
      next unless tags[tag_name]
      if return_tag && tags[tag_name].match(tag_value)
        results << tags[return_tag]
      elsif tags[tag_name].match(tag_value)
        results << instance
      end
    end
    return results.sort
  end

  Chef::Recipe.send(:include, Esor)

end
