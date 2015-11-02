require_relative 'spec_helper.rb'

context 'when only gRPC client is installed' do
  let(:main_self) { TOPLEVEL_BINDING.eval('self') }
  before(:example) do
    allow(main_self).to receive(:require).and_wrap_original do |orig, pkg|
      fail LoadError if pkg == 'cisco_os_shim/nxapi'
      orig.call(pkg)
    end
  end

  it 'should have gRPC client' do
    require 'cisco_os_shim'
    expect(Cisco::Shim::CLIENTS).to eql [Cisco::Shim::GRPC::Client]
  end
end
