Bind DDNS
=========

Description
-----------

Install and configure **ISC Bind** <https://www.isc.org/downloads/bind/> with
full Dynamic DNS support.

On client side, install **nsupdate**, provide a generic provider and a recipe
to update DNS entries.

Requirements
------------

### Cookbooks and gems

Declared in [metadata.rb](metadata.rb) and in [Gemfile](Gemfile).

### Platforms

- RHEL Family 7, tested on Centos

Note: it should work fine on Debian 8 but the official docker image does not
allow systemd to work easily, so it could not be tested.

Usage
-----

### Easy Setup

Add `recipe[bind-ddns::server]` in your run-list to install and configure
**Bind**. Configuration will be fetched from attributes `options`, `zones` and
`keys`.

To add a client, add `recipe[bind-ddns::client]`. **nsupdate** recipe will
update all records defined in `records`.

To see an example, look at [.kitchen.yml](.kitchen.yml).

### Test

This cookbook is fully tested through the installation of a server and a client
in docker hosts. This uses kitchen, docker and some monkey-patching.

If you run kitchen list, you will see 2 suites, Each corresponds to a different
server:

- server-ddns-centos-7: Bind server
- client-ddns-centos-7: DNS client with **nsupdate**

For more information, see [.kitchen.yml](.kitchen.yml) and [test](test)
directory.

Attributes
----------

Configuration is done by overriding default attributes. All configuration keys
have a default defined in [attributes/default.rb](attributes/default.rb).
Please read it to have a comprehensive view of what and how you can configure
this cookbook behavior.

Note: for fields needing an IP address, it is possible to set an interface
name, which will be resolved to its first non-local address.

Recipes
-------

### default

Call recipe **client**.

### package

Install **Bind** package.

### package-client

Install **Bind utils** package.

### config

Configure **Bind** server: *named.conf*, *keys* and *zones*.
Then check configuration through **named-checkconf**.

### service

Enable and start *named* service, subscribes on *named-checkconf* resource.

### nsupdate

Call **bind-ddns** default provider (which call **nsupdate** command) based on
attribute `records`. See [.kitchen.yml](.kitchen.yml) for more information.

### resolvconf

Set *resolv.conf* using `server` attribute.

### client

Install **Bind utils**, configure *resolv.conf* if requested (by attribute
`set_resolv_conf`) with recipe **resolvconf** and call **nsupdate** recipe.

### server

Install, configure and launch **Bind**. Then call **client** recipe.

Resources/Providers
-------------------

### default

Add or remove a DNS record using **nsupdate**:

Simple example:
```ruby
bind_ddns 'test.foo' do
  server ns.foo
  keyname foo
  secret XXXX
end
```

Add action `:delete` to delete an entry.

Changelog
---------

Available in [CHANGELOG](CHANGELOG).

Contributing
------------

Please read carefully [CONTRIBUTING.md](CONTRIBUTING.md) before making a merge
request.

License and Author
------------------

- Author:: Samuel Bernard (<samuel.bernard@s4m.io>)

```text
Copyright:: 2015, Sam4Mobile

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
