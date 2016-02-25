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

require 'socket'

# Internal module
module BindDdns
  def hash_resolve_iface(hash)
    result = {}
    hash.each do |key, value|
      result[resolve_iface(key)] = resolve_iface(value)
    end unless hash.nil?
    result
  end

  # iface may be an interface name, in the case we resolve its inet address
  def resolve_iface(iface)
    result = iface # if iface is not an interface, we do nothing

    ifaddrs = Socket.getifaddrs
    ifaces = ifaddrs.map(&:name).uniq
    # check if iface is an interface
    if ifaces.include? iface
      addrs = ipv4inets(ifaddrs, iface).map { |i| i.addr.ip_address }
      raise "No or multiple inet addresses for #{iface}" unless addrs.size == 1
      result = addrs.first
    end
    result
  end

  def ipv4inets(ifaddrs, iface)
    ifaddrs.select do |ifaddr|
      ifaddr.name == iface && !ifaddr.addr.nil? && ifaddr.addr.ipv4?
    end
  end
end
