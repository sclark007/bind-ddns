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

actions :add, :delete
default_action :add

attributes = [
  [ :uniq, :kind_of => [TrueClass, FalseClass], :default => true ],

  [ :server, :kind_of => String, :default => nil, :required => true ],
  [ :zone, :kind_of => String, :default => nil, :required => true ],
  [ :keyname, :kind_of => String, :default => nil, :required => true ],
  [ :secret, :kind_of => String, :default => nil, :required => true ],
  [ :hmac, :kind_of => String, :default => nil ],

  [ :other, :kind_of => String, :default => nil ],
  [ :cli_options, :kind_of => String, :default => nil ],

  [ :domain, :kind_of => String, :name_attribute => true ],
  [ :ttl, :kind_of => Integer, :default => 86400 ],
  [ :dnsclass, :kind_of => String, :default => 'IN' ],
  [ :type, :kind_of => String, :default => 'A' ],
  [ :data, :kind_of => String, :default => nil ]
]

attributes.each do |attr|
  attribute *attr
end
