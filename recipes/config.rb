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

# Keep track of any key files
key_files = []

# Write key files
node['bind-ddns']['keys'].each do |key|
  p key
  key = key.dup
  key['algorithm'] ||= node['bind-ddns']['default_key_algorithm']
  filename = "named-#{key['name']}.key"

  template File.join(node['bind-ddns']['config_dir'], filename) do
    source 'key.erb'
    owner node['bind-ddns']['user']
    group node['bind-ddns']['user']
    mode 0644
    variables 'key' => key
  end

  key_files << filename
end

# Write named configuration
template File.join(node['bind-ddns']['config_dir'], 'named.conf') do
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
end

# Write zone files
node['bind-ddns']['zones'].each do |zone|

  filename = zone['config']['file'].gsub(/\'|\"/, '')
  raise "No nameserver defined for zone #{zone['name']}" if zone['ns'].empty?

  template filename do
    path File.join(node['bind-ddns']['var_dir'], filename)
    source File.join(node['bind-ddns']['var_dir'], "#{filename}.erb")
    local true
    owner node['bind-ddns']['user']
    group node['bind-ddns']['user']
    mode 0644
    variables :serial => Time.now.to_i
    action :nothing
    #notifies :restart, "service[bind9]"
  end

  template File.join(node['bind-ddns']['var_dir'], "#{filename}.erb") do
    source 'zone.erb'
    owner node['bind-ddns']['user']
    group node['bind-ddns']['user']
    mode 0644
    variables({
      'global_ttl' => zone['global_ttl'],
      'contact' => zone['contact'],
      'ns' => zone['ns'],
      'a' => zone['a'],
      'refresh' => zone['refresh'],
      'retry' => zone['retry'],
      'expire' => zone['expire'],
      'negcachettl' => zone['negcachettl'],
      'extra_records' => zone['extra_records']
    })
    notifies :create, "template[#{filename}]", :immediately
  end unless zone['name'] == '"." IN'

end
