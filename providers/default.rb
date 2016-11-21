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

# Load our library
::Chef::Provider.send(:include, BindDdns)

use_inline_resources

action :add do
  nr = new_resource.to_hash
  nr[:data] = resolve_iface(nr[:data])
  current = check_current(nr[:domain], nr[:server])

  if nr[:uniq]
    different = current.select do |r|
      r[:type] == nr[:type] && (r[:data] != nr[:data] || r[:ttl] != nr[:ttl])
    end
    different.each { |r| nsupdate(nr.merge(r), 'del', r[:data]) }
  end

  same = current.select do |r|
    r[:type] == nr[:type] && r[:data] == nr[:data] && r[:ttl] == nr[:ttl]
  end
  if same.empty?
    nsupdate(nr, 'add', nr[:data])
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  nr = new_resource.to_hash
  nr[:data] = resolve_iface(nr[:data])
  current = check_current(nr[:domain], nr[:server])

  existing = current.select { |r| r[:type] == nr[:type] }
  return if existing.empty?
  if nr[:uniq]
    nsupdate(nr, 'delete', nil)
    new_resource.updated_by_last_action(true)
  else
    erase = existing.select do |r|
      r[:data] == nr[:data] && r[:ttl] == nr[:ttl]
    end
    erase.each do |r|
      nsupdate(nr.merge(r), 'delete', data)
      new_resource.updated_by_last_action(true)
    end
  end
end

def check_current(domain, server = nil)
  server = server.nil? ? '' : "@#{server}"
  dig = Mixlib::ShellOut.new("dig +noall +answer #{server} #{domain}")
  dig.run_command
  dig.stdout.lines.map(&:strip).map do |resource|
    hash = {}
    hash[:domain], hash[:ttl], hash[:dnsclass], hash[:type], hash[:data] =
      resource.split(' ')
    hash[:ttl] = hash[:ttl].to_i
    hash
  end
end

def nsupdate(nr, action, data)
  config = <<-EOS.gsub(/^ *$\n/, '')
    #{field('server', nr[:server] == 'localhost' ? '127.0.0.1' : nr[:server])}
    key #{nr[:keyname]} #{nr[:secret]}
    #{field('zone', nr[:zone])}
    #{create_update(nr, action, data)}
    send
  EOS
  execute "cat <<-EOF | nsupdate #{nr[:cli_options]}
    #{config}EOF
  "
end

def field(name, value)
  "#{name} #{value}" unless value.nil?
end

def create_update(nr, action, data)
  if action == 'add'
    "#{nr[:other]}\n  update #{action} " \
      "#{nr[:domain]} #{nr[:ttl]} #{nr[:dnsclass]} #{nr[:type]} #{data}"
  else
    "update #{action} #{nr[:domain]} #{nr[:type]} #{data}"
  end
end
