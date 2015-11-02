source 'https://rubygems.org'

# Specify the gem's dependencies in the .gemspec file
gemspec name: 'cisco_os_shim'

Dir['cisco_os_shim-*.gemspec'].each do |gemspec|
  plugin = gemspec.scan(/cisco_os_shim-(.*)\.gemspec/).flatten.first
  gemspec(name: "cisco_os_shim-#{plugin}", development_group: plugin)
end
