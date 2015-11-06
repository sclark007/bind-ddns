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
  resource = bind_ddns "nsupdate #{record['domain']}" do
    server node['bind-ddns']['server'] # Set global server as default
    action :add
  end

  # Get default zone name from tail part of domain (without the head)
  zone = record['zone']
  zone = record['domain'].split('.').drop(1).join('.') unless record['zone']
  zone = zone.gsub /\.$/, ''
  resource.zone zone

  # Fetch default key based on zone name
  keys = node['bind-ddns']['keys'].reject {|k| k['name'] != zone }
  unless keys.empty?
    raise "More than one key with name #{zone}!" if keys.size > 1
    key = keys.first
    resource.keyname key['name']
    resource.secret key['secret']
  end

  # Set all attributes, override defaults
  record.each do |name, value|
    resource.send(name, value)
  end
end
