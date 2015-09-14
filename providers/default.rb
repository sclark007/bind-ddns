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
  key = { 'hmac' => nr.hmac, 'keyname' => nr.keyname, 'secret' => nr.secret }
  data = resolve_iface nr.data
  current = check_current(nr.domain, data, nr.server)

  if nr.uniq
    expected = 0
    expected = 1 if current['present']
    if current['total'] > expected
      nsupdate(nr.cli_options, nr.server, key, nr.zone, 'del', nr.domain, nil,
               nil, nr.type, nil, nil)
      current['present'] = false
    end
  end

  unless current['present']
    nsupdate(nr.cli_options, nr.server, key, nr.zone, 'add', nr.domain, nr.ttl,
             nr.dnsclass, nr.type, data, nr.other)
    nr.updated_by_last_action(true)
  end
end

action :delete do
  nr = new_resource
  key = { 'hmac' => nr.hmac, 'keyname' => nr.keyname, 'secret' => nr.secret }
  data = resolve_iface nr.data
  current = check_current(nr.domain, data, nr.server)

  data = nr.uniq ? nil : data

  if current['present'] || (nr.uniq && current['total'] > 0)
    nsupdate(nr.cli_options, nr.server, key, nr.zone, 'del', nr.domain, nil,
             nil, nr.type, data, nil)
    nr.updated_by_last_action(true)
  end
end

def check_current(domain, ip, server)
  resolver = Resolv::DNS.new(:nameserver => server)
  addresses = resolver.getaddresses(domain).map(&:to_s)
  { 'total' => addresses.size, 'present' => addresses.include?(ip) }
end

def nsupdate(opt,server,key,zone,action,domain,ttl,dnsclass,type,data,other)
  data = resolve_iface data
  cmd = "nsupdate #{opt}"
  zone = "zone #{zone}" unless zone.nil?
  config = <<-EOS.gsub /^ *$\n/, ''
    server #{server}
    key #{key['hmac']} #{key['keyname']} #{key['secret']}
    #{zone}
    #{other}
    update #{action} #{domain} #{ttl} #{dnsclass} #{type} #{data}
    send
  EOS
  execute "cat <<-EOF | #{cmd}
    #{config}EOF
  "
end
