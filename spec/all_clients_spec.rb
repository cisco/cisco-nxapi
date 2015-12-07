require_relative 'spec_helper.rb'

context 'when both clients are installed' do
  it 'should have both clients' do
    require 'cisco_os_shim'
    expect(Cisco::Shim::CLIENTS).to eql [Cisco::Shim::NXAPI::Client,
                                         Cisco::Shim::GRPC::Client]
  end
end
