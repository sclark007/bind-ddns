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

describe command('echo "quit" | nsupdate') do
  its(:exit_status) { should eq 0 }
end

describe host('ns.chef.kitchen') do
  it { should be_reachable }
end

describe host('client-ddns.chef.kitchen') do
  it { should be_resolvable.by('dns') }
  expected = "client-ddns.chef.kitchen. 86400 IN A #{ip_eth0}\n"
  it "should resolve to eth0 ip: #{ip_eth0}" do
    expect(command(dig('client-ddns.chef.kitchen')).stdout).to eq(expected)
  end
end

describe host('test-multiple-a.chef.kitchen') do
  it { should be_resolvable.by('dns') }
  expected =
    "test-multiple-a.chef.kitchen. 86400 IN A 10.11.12.13\n"\
    "test-multiple-a.chef.kitchen. 86400 IN A 13.12.11.10\n"
  it 'should have 2 IPs' do
    expect(command(dig('test-multiple-a.chef.kitchen')).stdout).to eq(expected)
  end
end

describe host('test-delete.chef.kitchen') do
  it { should_not be_resolvable.by('dns') }
end

describe host('test-uniq.chef.kitchen') do
  it { should be_resolvable.by('dns') }
  expected = "test-uniq.chef.kitchen. 86400 IN A 30.31.32.33\n"
  it 'should have only one entry: 30.31.32.33' do
    expect(command(dig('test-uniq.chef.kitchen')).stdout).to eq(expected)
  end
end

describe host('test-cname.chef.kitchen') do
  it { should be_resolvable.by('dns') }
  cmd = "#{dig('test-cname.chef.kitchen')} | grep 'CNAME'"
  expected =
    "test-cname.chef.kitchen. 86400 IN CNAME client-ddns.chef.kitchen.\n"
  it "should have only one entry: #{ip_eth0}" do
    expect(command(cmd).stdout).to eq(expected)
  end
end
