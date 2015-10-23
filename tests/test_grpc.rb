#!/usr/bin/env ruby
#
# October 2015, Glenn F. Matthews
#
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

require_relative 'basetest'
require_relative '../lib/cisco_os_shim'

include Cisco::Shim::GRPC

# Test case for Cisco::Shim::GRPC::Client class
class TestGRPC < TestCase
  @@client = nil # rubocop:disable Style/ClassVars

  def client
    unless @@client
      client = Client.new(address, username, password)
      client.cache_enable = true
      client.cache_auto = true
      @@client = client # rubocop:disable Style/ClassVars
    end
    @@client
  end

  def test_config_string
    client.config("int gi0/0/0/0\ndescription panda\n")
    run = client.show('show run int gi0/0/0/0')
    assert_match(/description panda/, run)
  end

  def test_config_array
    client.config(['int gi0/0/0/0', 'description elephant'])
    run = client.show('show run int gi0/0/0/0')
    assert_match(/description elephant/, run)
  end

  def test_config_invalid
    e = assert_raises CliError do
      client.config(['int gi0/0/0/0', 'wark'])
    end
    # TODO: we need to parse the error message more precisely
    assert_match(/wark/, e.message)
    # Unlike NXAPI, a gRPC config command is always atomic
    assert_empty(e.successful_input)
    # TODO
    assert_equal('input TODO', e.rejected_input)
  end

  def test_exec
    result = client.exec('run echo hello')
    assert_match(/^hello$/, result)
  end

  def test_exec_invalid
    e = assert_raises CliError do
      client.exec('xyzzy')
    end
    # TODO: we need to parse the error message more precisely
    assert_match('xyzzy', e.message)
    assert_empty(e.successful_input)
    # TODO
    assert_equal('input TODO', e.rejected_input)
  end

  def test_exec_too_long
    assert_raises CliError do
      client.exec('0' * 500_000)
    end
    # TODO: error message validation
  end

  def test_show_ascii_default
    result = client.show('show debug')
    s = @device.cmd('show debug')
    assert_equal(result.strip, s.split("\n")[2].strip)
  end

  def test_show_ascii_invalid
    assert_raises CliError do
      client.show('show fuzz')
    end
  end

  def test_show_ascii_incomplete
    assert_raises CliError do
      client.show('show ')
    end
  end

  def test_show_ascii_explicit
    result = client.show('show debug', :ascii)
    s = @device.cmd('show debug')
    assert_equal(result.strip, s.split("\n")[2].strip)
  end

  def test_show_ascii_empty
    result = client.show('show debug | include foo | exclude foo', :ascii)
    assert_empty(result)
  end

  # TODO: add structured output test cases
  # TODO: add negative test cases for connection refused, auth fail, etc.

  def test_smart_create
    autoclient = Cisco::Shim::Client.create(address, username, password)
    assert_equal(Cisco::Shim::GRPC::Client, autoclient.class)
  end
end
