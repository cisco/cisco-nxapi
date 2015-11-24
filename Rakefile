require 'rubocop/rake_task'
require 'rake/testtask'
require 'rspec/core/rake_task'

def valid_gem?(input_gem)
  valid_gems = %w(core grpc nxapi)
  valid_gems.include?(input_gem)
end

# Test task is not part of default task list,
# because it requires a node to test against.
task default: %w(rubocop spec build)

RuboCop::RakeTask.new

# Because each of the below specs requires a clean Ruby environment,
# they need to be run individually instead of as a single RSpec task.
RSpec::Core::RakeTask.new(:spec_no_clients) do |t|
  t.pattern = 'spec/no_clients_spec.rb'
end
RSpec::Core::RakeTask.new(:spec_nxapi_only) do |t|
  t.pattern = 'spec/nxapi_only_spec.rb'
end
RSpec::Core::RakeTask.new(:spec_grpc_only) do |t|
  t.pattern = 'spec/grpc_only_spec.rb'
end
RSpec::Core::RakeTask.new(:spec_all_clients) do |t|
  t.pattern = 'spec/all_clients_spec.rb'
end

task spec: [:spec_no_clients,
            :spec_nxapi_only,
            :spec_grpc_only,
            :spec_all_clients,
           ]

task :build do
  system 'rm -f ./cisco_os_shim*.gem'
  gem_target = ENV['GEM']
  fail 'Invalid gem target' unless gem_target.nil? || valid_gem?(gem_target)
  if gem_target.nil?
    Dir['*.gemspec'].each { |gemspec| system "gem build #{gemspec}" }
  else
    system 'gem build cisco_os_shim.gemspec'
    next if gem_target == 'core'
    system "gem build cisco_os_shim-#{gem_target}.gemspec"
  end
end

task :validate do
  # Validate gem contents
  if system('gem specification ./*nxapi*gem | grep -v homepage | grep grpc')
    fail 'gRPC files in NXAPI gem!'
  end
  if system('gem specification ./*grpc*gem | grep -v homepage | grep nxapi')
    fail 'NXAPI files in gRPC gem!'
  end
  if system('gem specification ./*shim-1*gem | grep -v homepage | grep /nxapi')
    fail 'NXAPI files in core gem!'
  end
  if system('gem specification ./*shim-1*gem | grep -v homepage | grep /grpc')
    fail 'gRPC files in core gem!'
  end
  puts 'Sanity check complete.'
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'tests'
  t.pattern = 'tests/test_*.rb'
  t.warning = true
  t.verbose = true
end
