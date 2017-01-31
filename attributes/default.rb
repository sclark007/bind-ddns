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

# Set cookbook_name macro
cookbook_name = 'bind-ddns'

# Client/Server configuration
# A node is declared as server if its FQDN is included in the following
# attribute. See README for more information.
default[cookbook_name]['servers'] = []

# Installation options
default[cookbook_name]['package'] = 'bind'
default[cookbook_name]['package-utils'] = 'bind-utils'

default[cookbook_name]['user'] = 'named'
default[cookbook_name]['config_dir'] = '/etc'
default[cookbook_name]['var_dir'] = '/var/named'
default[cookbook_name]['service_name'] = 'named'

# Specific configuration depending on status (client or server)
default[cookbook_name]['client-config'] = {}
default[cookbook_name]['server-config'] = {}

# Set resolv.conf
default[cookbook_name]['set_resolv_conf'] = false
default[cookbook_name]['server'] = nil
default[cookbook_name]['secondary_servers'] = []
default[cookbook_name]['search'] = nil

# Global default port for nsupdate (and maybe one day for resolv.conf)
default[cookbook_name]['port'] = 53

# Default Bind options (as provided by centos package
default[cookbook_name]['options'] = {
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

default[cookbook_name]['keys'] = []
# Example of a key definition, algorithm is optional
# {
#   'name' => 'keyname',
#   'algorithm' => 'HMAC-MD5'
#   'secret' => 'XXXX'
# }
default[cookbook_name]['default_key_algorithm'] = 'HMAC-MD5'

# records declared to the server through nsupdate
# interface names will be resolved to their first non-local IP address
default[cookbook_name]['records'] = []
# Example of record
# {
#   'domain' => 'server.myzone',
#   'server' => 'localhost',
#   'data' => 'eth0'
# }

# Logging configuration
default[cookbook_name]['channels'] = [
  {
    'name' => 'default_debug',
    'config' => {
      'file' => '"data/named.run"',
      'severity' => 'dynamic'
    }
  }
]

default[cookbook_name]['categories'] = []

# Zones configuration
default[cookbook_name]['zones_default'] = {
  'global_ttl' => '1d',
  'refresh' => '3h',
  'retry' => '30m',
  'expire' => '4w',
  'negcachettl' => '1h',
  'extra_records' => []
}

default[cookbook_name]['zones'] = [
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
default[cookbook_name]['default_files'] = [
  'named.rfc1912.zones',
  'named.root.key'
]

default[cookbook_name]['included_files'] = []

# Configure retries for the package resources, default = global default (0)
# (mostly used for test purpose)
default[cookbook_name]['package_retries'] = nil
