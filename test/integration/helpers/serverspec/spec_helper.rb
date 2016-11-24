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

require 'serverspec'

set :backend, :exec

require 'socket'

def ip_eth0
  Socket.ip_address_list.find do |addr|
    addr.ipv4? && !addr.ipv4_loopback?
  end.ip_address
end

def dig(domain)
  "dig +noall +answer '#{domain}' | sort | sed 's/\\s\\+/ /g'"
end
