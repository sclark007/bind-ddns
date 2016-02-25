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
  its(:ipv4_address) { should eq ip_eth0 }
end

describe host('linux.client-ddns.chef.kitchen') do
  it { should be_resolvable.by('dns') }
  its(:ipv4_address) { should eq '10.11.12.13' }
end

describe host('test-delete.chef.kitchen') do
  it { should_not be_resolvable.by('dns') }
end
