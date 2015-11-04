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
  its(:ipv4_address) { should eq get_ip_eth0 }
end

describe host('server-ddns') do
  it { should be_resolvable.by('dns') }
  its(:ipv4_address) { should eq get_ip_eth0 }
end

describe file('/etc/resolv.conf') do
  its(:content) { should eq <<-eos.gsub(/^ {4}/, '') }
    # Produced by Chef -- changes will be overwritten

    search chef.kitchen
    nameserver 127.0.0.1
    nameserver 8.8.8.8
    nameserver 8.8.4.4
  eos
end

describe file('/etc/named.conf') do
  its(:content) { should contain 'listen-on port 53 { localnets; };' }
  its(:content) { should contain 'allow-query { localnets; };' }
  its(:content) { should contain 'recursion yes;' }
  its(:content) { should contain 'zone chef.kitchen {' }
  its(:content) { should contain 'file "dynamic/db-chef-kitchen";' }
  its(:content) { should contain 'include "/etc/named-chef-kitchen.key";' }
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
  its(:content) {
    should contain '@ IN SOA ns.chef.kitchen. hostmaster \('
  }
  its(:content) { should contain '  IN NS ns.chef.kitchen.' }
  its(:content) { should contain "ns.chef.kitchen. IN A #{get_ip_eth0}" }
end

describe command('named-checkconf -z /etc/named.conf') do
  its(:exit_status) { should eq 0 }
end

describe command(
  'named-checkzone chef.kitchen /var/named/dynamic/db-chef-kitchen') do
  its(:exit_status) { should eq 0 }
end
