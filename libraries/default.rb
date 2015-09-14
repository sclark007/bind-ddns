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

module BindDdns

  # iface may be an interface name, in the case we resolve its inet address
  def resolve_iface(iface)
    result = iface # if iface is not an interface, we do nothing
    # check if iface is an interface
    if node['network']['interfaces'].keys.include? iface
      addresses =  node['network']['interfaces'][iface]['addresses']
      inet = addresses.map do |address, info|
        address if info['family'] == 'inet'
      end.compact

      raise "No or multiple inet addresses for #{iface}" unless inet.size == 1
      result = inet.first
    end
    result
  end

end
