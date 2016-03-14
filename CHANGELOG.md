Changelog
=========

1.4.0
-----

Main:
- Can use specific options for clients or servers, to allow clients and
  servers to share the same role
  + Add an init recipe which initialize the configuration correctly
  + Modify default to choose between client and server recipe
  + client specific configurations should be in 'client-config' and
    servers in 'server-config'
  + the servers should be defined with 'servers' key
  + backward compatibility is not broken

- Switch to docker_cli, use prepared docker image
  + Switch kitchen driver from docker to docker_cli
  + Use sbernard/centos-systemd-kitchen image instead of bare centos
  + Remove privileged mode :)
  + Remove some now useless monkey patching
  + Fix a typo in kitchen_command, fixing kitchen create command

Misc:
- Fix default options not merged with user attributes
- Improve documentation, explain resource attributes and specific
  configurations
- Better tests, to test specific option behavior
- Fix all rubocop offenses
  + In particular, package-client recipe is renamed to package_client

1.3.1
-----

- Fix deprecated behavior (using nil as argument for a default resource)

1.3.0
-----

- Use lazy to simplify the definition of template "#{filepath}.erb"
- Small cleanup of default provider & resource, key info are required
- Fix idempotency by removing the block hack used to run the resource
- Add a test case on :delete for default provider

1.2.0
-----

- Add option for secondary servers in resolv.conf
- Reorganize README:
  + Move changelog from README to CHANGELOG
  + Move contribution guide to CONTRIBUTING.md
  + Reorder README, fix Gemfile missing
- Add Apache 2 license file

1.1.0
-----

- Fix failed run when a zone is reloaded while named is stopped
- Fix failed run when an interface name is used for its ip and this ip is
  fetched during the same run
- Fix failed run when a zone is modified while named is stopped
- Remove useless field 'hmac' in resource and provider

1.0.1
-----

- Fix default hostmaster email

1.0.0
-----

- Initial version with Centos 7 support
