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

# If server is a name, we assume it is localhost or an alias
server = node['bind-ddns']['server']
server_addr = !!(server =~ Resolv::IPv4::Regex) ? server : '127.0.0.1'

secondaries = [ node['bind-ddns']['secondary_servers'] ].flatten

template '/etc/resolv.conf' do
  source 'resolv.conf.erb'
  mode '0644'
  variables({
    'nameservers' => [ server_addr ] + secondaries,
    'search' => node['bind-ddns']['search']
  })
end
