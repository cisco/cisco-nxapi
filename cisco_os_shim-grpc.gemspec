# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cisco_os_shim/core/version'
require 'cisco_os_shim/grpc/version'

Gem::Specification.new do |spec|
  spec.name          = 'cisco_os_shim-grpc'
  spec.version       = Cisco::Shim::GRPC::VERSION
  spec.authors       = ['Glenn Matthews', 'Rob Gries']
  spec.email         = 'cisco_agent_gem@cisco.com'
  spec.summary       = \
    'Implementation of cisco_os_shim API for gRPC to IOS XR'
  spec.description   = <<-EOF
Implementation of cisco_os_shim API for gRPC to IOS XR.
Designed to be used with Puppet and Chef and the cisco_node_utils gem.
  EOF
  spec.license       = 'Apache-2.0'
  spec.homepage      = 'https://github.com/cisco/cisco-nxapi'

  spec.files         = `git ls-files | grep grpc`.split("\n")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'cisco_os_shim', Cisco::Shim::VERSION
  spec.add_runtime_dependency 'grpc', '~> 0.11'
end
