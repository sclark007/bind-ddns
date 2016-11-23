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

require 'spec_helper'

describe service('named') do
  it { should be_enabled }
  it { should be_running }
end

describe port(53) do
  it { should be_listening.with('tcp') }
end

describe host('ns.chef.kitchen') do
  it { should be_resolvable.by('dns') }
  expected = "ns.chef.kitchen. 86400 IN A #{ip_eth0}\n"
  it "should resolve to eth0 ip: #{ip_eth0}" do
    expect(command(dig('ns.chef.kitchen')).stdout).to eq(expected)
  end
end

describe host('server-ddns.chef.kitchen') do
  it { should be_resolvable.by('dns') }
  expected = "server-ddns.chef.kitchen. 86400 IN A #{ip_eth0}\n"
  it "should resolve to eth0 ip: #{ip_eth0}" do
    expect(command(dig('server-ddns.chef.kitchen')).stdout).to eq(expected)
  end
end

describe file('/etc/resolv.conf') do
  its(:content) { should contain <<-eos.gsub(/^ {4}/, '') }
    # Produced by Chef -- changes will be overwritten

    search chef.kitchen
    nameserver 127.0.0.1
  eos
end

grep = "grep '^nameserver' /etc/resolv.conf | grep -v 127.0.0.1"
nameservers = `#{grep} | cut -d" " -f2`.lines.map(&:chomp)
forwarders = "{ #{nameservers.map { |n| "#{n};" }.join(' ')} }"

describe file('/etc/named.conf') do
  its(:content) { should contain 'listen-on port 53 { localnets; };' }
  its(:content) { should contain 'allow-query { localnets; };' }
  its(:content) { should contain 'recursion yes;' }
  its(:content) { should contain 'zone chef.kitchen {' }
  its(:content) { should contain 'file "dynamic/db-chef-kitchen";' }
  its(:content) { should contain 'include "/etc/named-chef-kitchen.key";' }
  its(:content) { should contain "forwarders #{forwarders}" }
end

describe file('/etc/named-chef-kitchen.key') do
  its(:content) { should eq <<-eos.gsub(/^ {4}/, '') }
    // Produced by Chef -- changes will be overwritten

    key chef.kitchen {
      algorithm HMAC-MD5;
      secret "9ZDQZxLEBuho4+O0EuGOYA==";
    };
  eos
end

describe file('/var/named/dynamic/db-chef-kitchen.erb') do
  its(:content) { should contain '@ IN SOA ns.chef.kitchen. hostmaster \(' }
  its(:content) { should contain '  IN NS ns.chef.kitchen.' }
  its(:content) { should contain "ns.chef.kitchen. IN A #{ip_eth0}" }
end

describe command('named-checkconf -z /etc/named.conf') do
  its(:exit_status) { should eq 0 }
end

cmd = 'named-checkzone chef.kitchen /var/named/dynamic/db-chef-kitchen'
describe command(cmd) do
  its(:exit_status) { should eq 0 }
end
