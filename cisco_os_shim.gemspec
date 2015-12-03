# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cisco_os_shim/core/version'

Gem::Specification.new do |spec|
  spec.name          = 'cisco_os_shim'
  spec.version       = Cisco::Shim::VERSION
  spec.authors       = ['Rob Gries', 'Alex Hunsberger', 'Glenn Matthews',
                        'Chris Van Heuveln', 'Mike Wiebe', 'Jie Yang']
  spec.email         = 'cisco_agent_gem@cisco.com'
  spec.summary       = \
    'Abstraction layer for Cisco APIs (NX-OS NXAPI, IOS XR gRPC, etc.)'
  spec.description   = <<-EOF
Abstraction layer for Cisco APIs (NX-OS NXAPI, IOS XR gRPC, etc.)
Designed to be used with Puppet and Chef and the cisco_node_utils gem.
  EOF
  spec.license       = 'Apache-2.0'
  spec.homepage      = 'https://github.com/cisco/cisco-nxapi'

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'
  spec.required_rubygems_version = '>= 2.1.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '= 0.35.1'
  spec.add_development_dependency 'simplecov', '~> 0.9'

  spec.extensions = ['ext/mkrf_conf.rb']
end
