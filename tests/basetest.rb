#!/usr/bin/env ruby
#
# Basic unit test case class.
# December 2014, Glenn F. Matthews
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

require 'simplecov'
SimpleCov.start do
  # Don't calculate coverage of our test code itself!
  add_filter '/tests/'
end

require 'rubygems'
gem 'minitest', '~> 5.0'
require 'minitest/autorun'
require 'net/telnet'
require_relative '../lib/cisco_rpc/cisco_logger'

# rubocop:disable Style/ClassVars
# We *want* the address/username/password class variables to be shared
# with all child classes, so that we only need to initialize them once.

# TestCase - common base class for all minitest cases in this module.
class TestCase < Minitest::Test
  # These variables can be set in one of three ways:
  # 1) ARGV:
  #   $ ruby basetest.rb -- address[:port] username password
  # 2) NODE environment variable
  #   $ export NODE="address[:port] username password"
  #   $ rake test
  # 3) At run time:
  #   $ rake test
  #   Enter address or hostname of node under test:
  @@address = nil
  @@username = nil
  @@password = nil

  def address
    @@address ||= ARGV[0]
    @@address ||= ENV['NODE'].split(' ')[0] if ENV['NODE']
    unless @@address
      print 'Enter address or hostname of node under test: '
      @@address = gets.chomp
    end
    @@address
  end

  def username
    @@username ||= ARGV[1]
    @@username ||= ENV['NODE'].split(' ')[1] if ENV['NODE']
    unless @@username
      print 'Enter username for node under test:           '
      @@username = gets.chomp
    end
    @@username
  end

  def password
    @@password ||= ARGV[2]
    @@password ||= ENV['NODE'].split(' ')[2] if ENV['NODE']
    unless @@password
      print 'Enter password for node under test:           '
      @@password = gets.chomp
    end
    @@password
  end

  def setup
    @device = Net::Telnet.new('Host'    => address.split(':')[0],
                              'Timeout' => 240,
                              # NX-OS has a space after '#', IOS XR does not
                              'Prompt'  => /[$%#>] *\z/n,
                             )
    begin
      @device.login('Name'        => username,
                    'Password'    => password,
                    # NX-OS uses 'login:' while IOS XR uses 'Username:'
                    'LoginPrompt' => /(?:[Ll]ogin|[Uu]sername)[: ]*\z/n,
                   )
    rescue Errno::ECONNRESET
      # TODO
      puts 'Connection reset by peer? Try again'
      sleep 1
      @device = Net::Telnet.new('Host'    => address.split(':')[0],
                                'Timeout' => 240,
                                # NX-OS has a space after '#', IOS XR does not
                                'Prompt'  => /[$%#>] *\z/n,
                               )
      @device.login('Name'        => username,
                    'Password'    => password,
                    # NX-OS uses 'login:' while IOS XR uses 'Username:'
                    'LoginPrompt' => /(?:[Ll]ogin|[Uu]sername)[: ]*\z/n,
                   )
    end
    CiscoLogger.debug_enable if ARGV[3] == 'debug' || ENV['DEBUG'] == '1'
  rescue Errno::ECONNREFUSED
    puts 'Telnet login refused - please check that the IP address is correct'
    puts "  and that you have enabled 'feature telnet' on the UUT"
    exit
  end

  def teardown
    @device.close unless @device.nil?
    GC.start
  end
end
