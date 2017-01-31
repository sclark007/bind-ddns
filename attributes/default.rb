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

# Client/Server configuration
# A node is declared as server if its FQDN is included in the following
# attribute. See README for more information.
default['bind-ddns']['servers'] = []

# Installation options
default['bind-ddns']['package'] = 'bind'
default['bind-ddns']['package-utils'] = 'bind-utils'

default['bind-ddns']['user'] = 'named'
default['bind-ddns']['config_dir'] = '/etc'
default['bind-ddns']['var_dir'] = '/var/named'
default['bind-ddns']['service_name'] = 'named'

# Specific configuration depending on status (client or server)
default['bind-ddns']['client-config'] = {}
default['bind-ddns']['server-config'] = {}

# Set resolv.conf
default['bind-ddns']['set_resolv_conf'] = false
default['bind-ddns']['server'] = nil
default['bind-ddns']['secondary_servers'] = []
default['bind-ddns']['search'] = nil

# Global default port for nsupdate (and maybe one day for resolv.conf)
default['bind-ddns']['port'] = 53

# Default Bind options (as provided by centos package
default['bind-ddns']['options'] = {
  'listen-on' => 'port 53 { 127.0.0.1; }',
  'listen-on-v6' => 'port 53 { ::1; }',
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
#   'algorithm' => 'HMAC-MD5'
#   'secret' => 'XXXX'
# }
default['bind-ddns']['default_key_algorithm'] = 'HMAC-MD5'

# records declared to the server through nsupdate
# interface names will be resolved to their first non-local IP address
default['bind-ddns']['records'] = []
# Example of record
# {
#   'domain' => 'server.myzone',
#   'server' => 'localhost',
#   'data' => 'eth0'
# }

# Logging configuration
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

# Zones configuration
default['bind-ddns']['zones_default'] = {
  'global_ttl' => '1d',
  'refresh' => '3h',
  'retry' => '30m',
  'expire' => '4w',
  'negcachettl' => '1h',
  'extra_records' => []
}

default['bind-ddns']['zones'] = [
  {
    'name' => '"." IN',
    'config' => {
      'type' => 'hint',
      'file' => 'named.ca'
    }
  }
  # Example with a user-defined zone
  # {
  #   'name' => 'myzone',
  #   'config' => {
  #     'type' => 'master',
  #     'file' => '"master/myzone"'
  #   },
  #   'ns' => [ 'ns.myzone' ],
  #   'a' => {
  #     # interface names will be resolved to their first non-local IP address
  #     'ns.myzone' => 'eth0'
  #   }
  #   'contact' => "foo.zone.com.", # default is hostmaster
  #   'serial' => 123 # set it ONLY if you want to force the serial
  #       # by default (ie if nil), it uses the current unix time
  #
  #   # other fields have default defined in 'zones_default'
  # }
]

# Included file (from named.conf)
default['bind-ddns']['default_files'] = [
  'named.rfc1912.zones',
  'named.root.key'
]

default['bind-ddns']['included_files'] = []

# Configure retries for the package resources, default = global default (0)
# (mostly used for test purpose)
default['bind-ddns']['package_retries'] = nil
