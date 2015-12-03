# Copyright (c) 2015 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'cisco_os_shim'

# Fail gracefully if submodule dependencies are not met
begin
  require 'net_http_unix'
rescue LoadError => e
  raise unless e.message =~ /-- net_http_unix/
  # If grpc is not installed, raise an error that cisco_os_shim understands.
  raise LoadError, "Unable to load cisco_os_shim/nxapi -- #{e}"
end

# Namespace for Cisco NXAPI-specific code
module Cisco::Shim::NXAPI
end

# Auto-load all Ruby files in the subdirectory
Dir.glob(__dir__ + '/nxapi/*.rb') { |file| require file }
