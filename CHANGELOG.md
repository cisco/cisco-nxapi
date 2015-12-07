Changelog
=========

Unreleased
----------

### Incompatibilities with version 1.0.0

* Gem name has changed from `cisco_nxapi` to `cisco_os_shim`
* Namespace restructuring:
  * Added `Cisco::Shim` namespace for code shared between clients
  * Added `Cisco::Shim::GRPC` and `Cisco::Shim::NXAPI` namespaces for API-specific code
  * `CiscoNxapi` namespace is no more. Some names have moved into `Cisco::Shim` and others into `Cisco::Shim::NXAPI`, depending on their generalizability to gRPC:
    * `CiscoNxapi::NxapiClient` --> `Cisco::Shim::NXAPI::Client` (and abstract parent class `Cisco::Shim::Client`)
    * `CiscoNxapi::NxapiError` --> `Cisco::Shim::ShimError`
    * `CiscoNxapi::CliError` --> `Cisco::Shim::NXAPI::CliError` (and API-agnostic parent class `Cisco::Shim::RequestFailed`)
    * `CiscoNxapi::HTTPBadRequest` --> `Cisco::Shim::Nxapi::HTTPBadRequest`
    * `CiscoNxapi::HTTPUnauthorized` --> `Cisco::Shim::HTTPUnauthorized` (and API-agnostic parent class `Cisco::Shim::AuthenticationFailed`)
    * `CiscoNxapi::RequestNotSupported` --> `Cisco::Shim::RequestNotSupported`
    * `CiscoNxapi::ConnectionRefused` --> `Cisco::Shim::ConnectionRefused`
* Ruby 1.9.3 is no longer supported - minimum Ruby version is 2.0.0

### Added

* Now supports gRPC API for clients on IOS XR 6.0.0.
  * Smart dependency installation - installing this gem will install `grpc` on IOS XR and Linux environments, but not on NX-OS environments.
  * Clients now have `platform` and `supports?` APIs to query whether a given client is `:nexus` or `ios_xr` and whether it supports configuration by `:cli`.
* NXAPI - Better handling of empty output from cli_show_ascii requests (@hunner).
* Enabled [Travis-CI](https://travis-ci.org) integration to automatically run [rubocop](https://github.com/bbatsov/rubocop).
* Minitest enhancements:
  * Code coverage calculation using [SimpleCov]
  * UUT can be specified by the `NODE` environment variable or at runtime, in addition to the classic method of command line arguments to `ruby test_my_file.rb`

### Fixed

* Fixed all outstanding rubocop warnings.

### Changed

* Now requires Minitest ~> 5.0 instead of Minitest < 5.0.

### Removed

* Removed `test_all_cisco.rb` as NXAPI and gRPC tests cannot be run simultaneously.

1.0.0
-----

* Change the http read timeout from default 60 seconds to 300 seconds.
* Recognize and handle NXAPI error code 413 (request too large).

0.9.0
-----

* First public release, corresponding to Early Field Trial (EFT) of
  Cisco NX-OS 7.0(3)I2(1).

[SimpleCov]: https://github.com/colszowka/simplecov
