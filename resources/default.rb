#
# Copyright (c) 2015-2017 Sam4Mobile
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

actions :add, :delete
default_action :add

attributes = [
  # If the defined domain must have only one entry for the given type.
  # Ex: if type is 'A', remove all other 'A' entries (even with action delete)
  [:uniq, kind_of: [TrueClass, FalseClass], default: true],

  # DNS server, authoritative on the zone
  [:server, kind_of: String, default: nil],
  # DNS server port
  [:port, kind_of: Integer, default: 53],
  # DNS Zone to add the entry
  [:zone, kind_of: String, default: nil],
  # Name of DDNS Key
  [:keyname, kind_of: String, required: true],
  # Secret of DDNS Key
  [:secret, kind_of: String, required: true],

  # Whatever that could have been forgotten
  [:other, kind_of: String, default: nil],
  # Options for nsupdate command
  [:cli_options, kind_of: String, default: nil],

  # Domain of the entry
  [:domain, kind_of: String, name_attribute: true],
  # TTL of the entry
  [:ttl, kind_of: Integer, default: 86_400],
  # DNS Class
  [:dnsclass, kind_of: String, default: 'IN'],
  # DNS Type
  [:type, kind_of: String, default: 'A'],
  # IPV4 (A)/ IPV6 (AAAA) / Name (CNAME), etc.
  [:data, kind_of: String, default: nil]
]

attributes.each do |attr|
  attribute(*attr)
end
