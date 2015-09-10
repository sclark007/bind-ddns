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

use_inline_resources

action :add do
  nr = new_resource

  cmd = "nsupdate #{nr.cli_options}"

  config = <<-EOS.gsub /^ *$\n/, ''
    server #{nr.server}
    key #{nr.hmac} #{nr.keyname} #{nr.secret}
    zone #{nr.zone}
    #{nr.other}
    update add #{nr.domain} #{nr.ttl} #{nr.dnsclass} #{nr.type} #{nr.data}
    send
  EOS

  execute "cat <<-EOF | #{cmd}
    #{config}EOF
  "
end

action :delete do
end
