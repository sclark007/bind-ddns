#
# Copyright (c) 2015-2016 Sam4Mobile
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

# Config initialization
include_recipe "#{cookbook_name}::init"
config = node.run_state['bind-ddns']['config']

# Load our library
::Chef::Recipe.send(:include, BindDdns)
::Chef::Resource.send(:include, BindDdns)

# Keep track of any key files
key_files = []

# Write key files
config['keys'].each do |key|
  key = key.dup
  key['algorithm'] ||= config['default_key_algorithm']
  filename = "named-#{key['name'].tr('.', '-')}.key"

  template ::File.join(config['config_dir'], filename) do
    source 'key.erb'
    owner config['user']
    group config['user']
    mode 0644
    variables 'key' => key
    notifies :run, 'execute[named-checkconf]', :delayed
  end

  key_files << filename
end

# Write named configuration
named_conf = ::File.join(config['config_dir'], 'named.conf')

template named_conf do
  source 'named.conf.erb'
  mode '644'
  variables(
    'options' => config['options'],
    'channels' => config['channels'],
    'categories' => config['categories'],
    'zones' => config['zones'],
    'included_files' => config['default_files'].dup +
      config['included_files'] + key_files,
    'config_dir' => config['config_dir']
  )
  notifies :run, 'execute[named-checkconf]', :delayed
end

# Write zone files
config['zones'].each do |zone|
  # Check configuration completeness
  prefix = "#{cookbook_name}::#{recipe_name}: zone #{zone['name']}:"

  %w(name config).each do |field|
    raise "#{prefix} mandatory field '#{field}' is nil" if zone[field].nil?
  end

  %w(type file).each do |field|
    if zone['config'][field].nil?
      raise "#{prefix} mandatory field 'config/#{field}' is nil"
    end
  end

  # For a master zone, we need A and NS records
  if zone['config']['type'] == 'master'
    %w(ns a).each do |field|
      raise "#{prefix} mandatory field '#{field}' is nil" if zone[field].nil?
    end

    # NS entries must have a match in A records
    unless zone['ns'].map { |ns| zone['a'].keys.include? ns }.all?
      raise "#{prefix} some nameservers defined in 'ns' does not" \
        'have a corresponding A entry'
    end

    raise "No nameserver defined for zone #{zone['name']}" if zone['ns'].empty?
  end

  filename = zone['config']['file'].gsub(/\'|\"/, '')
  filepath = ::File.join(config['var_dir'], filename)

  status = Mixlib::ShellOut.new('rndc status')
  z_exists = if ::File.exist?('/etc/rndc.key') && ::File.exist?(filepath)
               status.run_command
               !status.error?
             else false
             end

  # Freeze and reload the zone if it exists (condition in notifies)
  execute "freeze #{zone['name']}" do
    command "rndc freeze #{zone['name']}"
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
    owner config['user']
    group config['user']
    mode 0644
    variables serial: zone['serial'] || Time.now.to_i
    action :nothing
  end

  # Remove zone journal if named is stopped and the zone has been modified
  file "#{filepath}.jnl" do
    action :nothing
  end

  default = config['zones_default']

  # Create a template with everything except the serial
  template "#{filepath}.erb" do
    source 'zone.erb'
    owner config['user']
    group config['user']
    mode 0644
    variables(
      lazy do
        {
          'global_ttl' => zone['global_ttl'] || default['global_ttl'],
          'contact' => zone['contact'] || 'hostmaster',
          'ns' => zone['ns'],
          'a' => hash_resolve_iface(zone['a']),
          'refresh' => zone['refresh'] || default['refresh'],
          'retry' => zone['retry'] || default['retry'],
          'expire' => zone['expire'] || default['expire'],
          'negcachettl' => zone['negcachettl'] || default['negcachettl'],
          'extra_records' => zone['extra_records'] || default['extra_records']
        }
      end
    )
    notifies :delete, "file[#{filepath}.jnl]", :immediately unless z_exists
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
