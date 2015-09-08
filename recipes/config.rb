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

conf_vars = {
  'options' => node['bind-ddns']['options'],
  'channels' => node['bind-ddns']['channels'],
  'categories' => node['bind-ddns']['categories'],
  'zones' => node['bind-ddns']['zones'],
  'included_files' => node['bind-ddns']['default_files'].dup +
    node['bind-ddns']['included_files'],
  'config_dir' => node['bind-ddns']['config_dir']
}

# Write configuration
template "/#{node['bind-ddns']['config_dir']}/named.conf" do
  source "named.conf.erb"
  mode '644'
  variables conf_vars
 end
