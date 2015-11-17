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

require_relative 'cisco_os_shim/core'

# Try to load known extensions
extensions = ['cisco_os_shim/nxapi',
              'cisco_os_shim/grpc',
             ]
extensions.each do |ext|
  begin
    require ext
  rescue LoadError => e
    # ignore missing cisco_os_shim-(grpc|nxapi), they're not always required
    raise unless e.message =~ /#{Regexp.escape(ext)}/
  end
end
