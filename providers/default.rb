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
::Chef::Provider.send(:include, BindDdns)

use_inline_resources

action :add do
  nr = new_resource
  key = {
    'keyname' => nr.keyname,
    'secret' => nr.secret
  }
  data = resolve_iface nr.data
  current = check_current(nr.domain, data, nr.server)

  if nr.uniq
    expected = 0
    expected = 1 if current['present']
    if current['total'] > expected
      nsupdate(nr, key, 'del', nil)
      current['present'] = false
    end
  end

  unless current['present']
    nsupdate(nr, key, 'add', data)
    nr.updated_by_last_action(true)
  end
end

action :delete do
  nr = new_resource
  key = {
    'keyname' => nr.keyname,
    'secret' => nr.secret
  }
  data = resolve_iface nr.data
  current = check_current(nr.domain, data, nr.server)

  data = nr.uniq ? nil : data

  if current['present'] || (nr.uniq && current['total'] > 0)
    nsupdate(nr, key, 'del', data)
    nr.updated_by_last_action(true)
  end
end

def check_current(domain, ip, server)
  resolver = Resolv::DNS.new(server.nil? ? nil : { nameserver: server })
  addresses = resolver.getaddresses(domain).map(&:to_s)
  resolver.close
  { 'total' => addresses.size, 'present' => addresses.include?(ip) }
end

def nsupdate(nr, key, action, data)
  config = <<-EOS.gsub(/^ *$\n/, '')
    #{field('server', nr.server)}
    key #{key['keyname']} #{key['secret']}
    #{field('zone', nr.zone)}
    #{create_update(nr, action, data)}
    send
  EOS
  execute "cat <<-EOF | nsupdate #{nr.cli_options}
    #{config}EOF
  "
end

def field(name, value)
  "#{name} #{value}" unless value.nil?
end

def create_update(nr, action, data)
  if action == 'add'
    "#{nr.other}\n  update " \
      "#{action} #{nr.domain} #{nr.ttl} #{nr.dnsclass} #{nr.type} #{data}"
  else
    "update #{action} #{nr.domain} #{nr.type} #{data}"
  end
end
