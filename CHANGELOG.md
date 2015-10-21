Changelog
=========

Unreleased
----------

### Added

* Better handling of empty output from cli_show_ascii requests (@hunner).
* Enabled [Travis-CI](https://travis-ci.org) integration to automatically run [rubocop](https://github.com/bbatsov/rubocop).
* Minitest enhancements:
  * Code coverage calculation using [SimpleCov]
  * Full Minitest suite can be run by `rake test`
  * UUT can be specified by the `NODE` environment variable or at runtime, in addition to the classic method of command line arguments to `ruby test_my_file.rb`

### Fixed

* Fixed all outstanding rubocop warnings.

### Changed

* Now requires Minitest ~> 5.0 instead of Minitest < 5.0.

### Removed

* Dropped support for Ruby 1.9.3 as it is end-of-life.
* Removed `test_all_cisco.rb` as `rake test` can auto-discover all tests.

1.0.0
-----

* Change the http read timeout from default 60 seconds to 300 seconds.
* Recognize and handle NXAPI error code 413 (request too large).

0.9.0
-----

* First public release, corresponding to Early Field Trial (EFT) of
  Cisco NX-OS 7.0(3)I2(1).

[SimpleCov]: https://github.com/colszowka/simplecov
