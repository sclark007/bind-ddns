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

default['bind-ddns']['package'] = 'bind'
default['bind-ddns']['package-utils'] = 'bind-utils'

default['bind-ddns']['user'] = 'named'
default['bind-ddns']['config_dir'] = '/etc'
default['bind-ddns']['var_dir'] = '/var/named'

default['bind-ddns']['options'] = {
  'listen-on port' => '53 { 127.0.0.1; }',
  'listen-on-v6 port' => '53 { ::1; }',
  'directory' => '"/var/named"',
  'dump-file' => '"/var/named/data/cache_dump.db"',
  'statistics-file' => '"/var/named/data/named_stats.txt"',
  'memstatistics-file' => '"/var/named/data/named_mem_stats.txt"',
  'allow-query' => '{ localhost; }',
  'recursion' => 'yes',
  'dnssec-enable' => 'yes',
  'dnssec-validation' => 'yes',
  'dnssec-lookaside' => 'auto',
  'bindkeys-file' => '"/etc/named.iscdlv.key"',
  'managed-keys-directory' => '"/var/named/dynamic"',
  'pid-file' => '"/run/named/named.pid"',
  'session-keyfile' => '"/run/named/session.key"'
}

default['bind-ddns']['keys'] = []
# Example of a key definition, algorithm is optional
# {
#   'name' => 'keyname',
#   algorithm => 'HMAC-MD5'
#   secret => 'XXXX'
# }
default['bind-ddns']['default_key_algorithm'] = 'HMAC-MD5'

default['bind-ddns']['channels'] = [
  {
    'name' => 'default_debug',
    'config' => {
      'file' => '"data/named.run"',
      'severity' => 'dynamic'
    }
  }
]

default['bind-ddns']['categories'] = []

default['bind-ddns']['zones'] = [
  {
    'name' => '"." IN',
    'config' => {
      'type' => 'hint',
      'file' => '"named.ca"'
    }
  }
  # Example with a user-defined zone
  # {
  #   'name' => 'myzone',
  #   'config' => {
  #     'type' => 'master',
  #     'file' => '"master/myzone"'
  #   },
  #   global_ttl => 1d,
  #   contact => "foo@myzone",
  #   ns => [],
  #   refresh => 3h,
  #   retry => 30m,
  #   expire => 4w,
  #   negcachettl => 1h,
  #   extra_records => []
  # }
]

default['bind-ddns']['default_files'] = [
  'named.rfc1912.zones',
  'named.root.key'
]

default['bind-ddns']['included_files'] = []
