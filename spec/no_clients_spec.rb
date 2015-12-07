require_relative 'spec_helper.rb'

context 'when loading the core code explicitly' do
  it 'should not have any clients' do
    require 'cisco_os_shim/core'
    expect(Cisco::Shim::CLIENTS).to eql []
  end
end

require 'rspec/core'

context 'when no client implementations are installed' do
  let(:main_self) { TOPLEVEL_BINDING.eval('self') }

  before(:example) do
    allow(main_self).to receive(:require).and_wrap_original do |orig, pkg|
      fail LoadError, pkg if pkg['cisco_os_shim/nxapi']
      fail LoadError, pkg if pkg['cisco_os_shim/grpc']
      orig.call(pkg)
    end
  end

  it 'should not have any clients' do
    require 'cisco_os_shim'
    expect(Cisco::Shim::CLIENTS).to eql []
  end

  it 'should fail Client.create' do
    require 'cisco_os_shim'
    expect { Cisco::Shim::Client.create('1.1.1.1', 'u', 'p') }.to \
      raise_error(RuntimeError, 'No client implementations available!')
  end
  # TODO
end
