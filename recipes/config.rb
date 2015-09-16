#
# Copyright (c) 2015 Sam4Mobile
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Load our library
::Chef::Recipe.send(:include, BindDdns)

# Keep track of any key files
key_files = []

# Write key files
node['bind-ddns']['keys'].each do |key|
  key = key.dup
  key['algorithm'] ||= node['bind-ddns']['default_key_algorithm']
  filename = "named-#{key['name']}.key"

  template ::File.join(node['bind-ddns']['config_dir'], filename) do
    source 'key.erb'
    owner node['bind-ddns']['user']
    group node['bind-ddns']['user']
    mode 0644
    variables 'key' => key
    notifies :run, 'execute[named-checkconf]', :delayed
  end

  key_files << filename
end

# Write named configuration
named_conf = ::File.join(node['bind-ddns']['config_dir'], 'named.conf')

template named_conf do
  source 'named.conf.erb'
  mode '644'
  variables({
    'options' => node['bind-ddns']['options'],
    'channels' => node['bind-ddns']['channels'],
    'categories' => node['bind-ddns']['categories'],
    'zones' => node['bind-ddns']['zones'],
    'included_files' => node['bind-ddns']['default_files'].dup +
      node['bind-ddns']['included_files'] + key_files,
    'config_dir' => node['bind-ddns']['config_dir']
  })
  notifies :run, 'execute[named-checkconf]', :delayed
end

# Write zone files
node['bind-ddns']['zones'].each do |zone|

  filename = zone['config']['file'].gsub(/\'|\"/, '')
  filepath = ::File.join(node['bind-ddns']['var_dir'], filename)
  raise "No nameserver defined for zone #{zone['name']}" if zone['ns'].empty?

  z_exists = ::File.exist?('/etc/rndc.key') && ::File.exist?(filepath)

  # Freeze and reload the zone if it exists (condition in notifies)
  execute "freeze #{zone['name']}" do
    command "rndc freeze #{zone['name']} | true"
    action :nothing
  end

  execute "restart #{zone['name']}" do
    command "rndc reload #{zone['name']} && rndc thaw #{zone['name']}"
    action :nothing
  end

  # Change the serial only if the rest has changed
  template filename do
    path filepath
    source "#{filepath}.erb"
    local true
    owner node['bind-ddns']['user']
    group node['bind-ddns']['user']
    mode 0644
    variables :serial => zone['serial'] || Time.now.to_i
    action :nothing
  end

  # Interpret interface name to replace them with their inet address
  resolved_zone_a = hash_resolve_iface(zone['a'])

  # Create a template with everything except the serial
  template "#{filepath}.erb" do
    source 'zone.erb'
    owner node['bind-ddns']['user']
    group node['bind-ddns']['user']
    mode 0644
    variables({
      'global_ttl' => zone['global_ttl'],
      'contact' => zone['contact'],
      'ns' => zone['ns'],
      'a' => resolved_zone_a,
      'refresh' => zone['refresh'],
      'retry' => zone['retry'],
      'expire' => zone['expire'],
      'negcachettl' => zone['negcachettl'],
      'extra_records' => zone['extra_records']
    })
    notifies :run, "execute[freeze #{zone['name']}]", :immediately if z_exists
    notifies :create, "template[#{filename}]", :immediately
    notifies :run, "execute[restart #{zone['name']}]", :immediately if z_exists
    notifies :run, 'execute[named-checkconf]', :delayed
  end unless zone['name'] == '"." IN'

end

# Check if the configuration is OK
execute 'named-checkconf' do
  command "/usr/sbin/named-checkconf -z #{named_conf}"
  action :nothing
end
