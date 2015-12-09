# `cisco_os_shim` - Cisco Operating System Shim

[![Gem Version](https://badge.fury.io/rb/cisco_os_shim.svg)](http://badge.fury.io/rb/cisco_os_shim)
[![Build Status](https://travis-ci.org/cisco/cisco-os-shim.svg?branch=develop)](https://travis-ci.org/cisco/cisco-os-shim)

The `cisco_os_shim` gem provides an abstract interface for communicating with
Cisco network nodes running various Cisco operating systems. Currently the
following nodes and operating systems are supported:

- Nexus switches running NX-OS 7.0(3)I2(1) and later (via the NX-API management API).
- Routers running IOS XR 6.0.0 and later (via gRPC).

For a greater level of abstraction, use the [CiscoNodeUtils gem](https://rubygems.org/gems/cisco_node_utils).

## Installation

To install the `cisco_os_shim` gem, use the following command:

    $ gem install cisco_os_shim

(Add `sudo` if you're installing under a POSIX system as root)

## Examples

This gem can be used directly on a Cisco device (as used by Puppet and Chef)
or can run on a workstation and point to a Cisco device (as used by the
included minitest suite).

In either case, unless you want to explicitly specify the client implementation class in use, you can simply `require 'cisco_os_shim'` (which will automatically discover available client implementations) and use the `Cisco::Shim::Client.create` API to automatically determine the correct implementation to use.

### Usage on a Cisco device

```ruby
require 'cisco_os_shim'

client = Cisco::Shim::Client.create

client.show("show version")

client.config(["interface ethernet1/1",
               "description Managed by NX-API",
               "no shutdown"])
```

### Remote usage

```ruby
require 'cisco_os_shim'

client = Cisco::Shim::Client.create("n3k.mycompany.com",
                                    "username", "password")

client.show("show version")

client.config(["interface ethernet1/1",
               "description Managed by NX-API",
               "no shutdown"])
```

## Changelog

See [CHANGELOG](CHANGELOG.md) for a list of changes.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## License

Copyright (c) 2013-2015 Cisco and/or its affiliates.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
