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

records = node['bind-ddns']['records']

records.each do |record|
  resource = Chef::Resource::BindDdns.new(
    record['domain'], run_context
  )
  resource.cookbook_name= cookbook_name
  resource.recipe_name= recipe_name

  # Get default zone name from last part of domain
  zone = record['zone']
  zone = record['domain'].split('.').last unless record['zone']
  zone = zone.gsub /\.$/, ''
  resource.zone zone

  # Fetch default key based on zone name
  keys = node['bind-ddns']['keys'].reject {|k| k['name'] != zone }
  unless keys.empty?
    raise "More than one key with name #{zone}!" if keys.size > 1
    key = keys.first
    resource.keyname key['name']
    resource.secret key['secret']
    resource.hmac key['hmac']
  end

  # Set global server as default
  resource.server node['bind-ddns']['server']

  # Set all attributes, override defaults
  record.each do |name, value|
    resource.send(name, value)
  end

  action = record['action']
  action = :add if action.nil?
  ruby_block "run bind-ddns[#{record['domain']}]" do
    block do
      resource.run_action action
    end
  end
end
