require_relative 'spec_helper.rb'

context 'when only NXAPI client is installed' do
  let(:main_self) { TOPLEVEL_BINDING.eval('self') }
  before(:example) do
    allow(main_self).to receive(:require).and_wrap_original do |orig, pkg|
      fail LoadError, pkg if pkg['cisco_os_shim/grpc']
      orig.call(pkg)
    end
  end

  it 'should have NXAPI client' do
    require 'cisco_os_shim'
    expect(Cisco::Shim::CLIENTS).to eql [Cisco::Shim::NXAPI::Client]
  end
end
