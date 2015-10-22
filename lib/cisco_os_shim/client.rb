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

require_relative 'client_errors'

module Cisco::Shim
  # Base class for clients of various RPC formats
  class Client
    def initialize(address=nil, username=nil, password=nil)
      @address = address
      @username = username
      @password = password
      @cache_enable = true
      @cache_auto = true
      cache_flush
    end

    def cache_enable?
      @cache_enable
    end

    def cache_enable=(enable)
      @cache_enable = enable
      cache_flush unless enable
    end

    def cache_auto?
      @cache_auto
    end

    attr_writer :cache_auto

    # Clear the cache of CLI output results.
    #
    # If cache_auto is true (default) then this will be performed automatically
    # whenever a config() or exec() is called, but providers may also call this
    # to explicitly force the cache to be cleared.
    def cache_flush
      # to be implemented by subclasses
    end

    # Configure the given command(s) on the device.
    #
    # @raise [RequestFailed] if the configuration fails
    #
    # @param commands [String, Array<String>] either of:
    #   1) The configuration sequence, as a newline-separated string
    #   2) An array of command strings (one command per string, no newlines)
    def config(commands) # rubocop:disable Lint/UnusedMethodArgument
      cache_flush if cache_auto?
      # to be implemented by subclasses
    end

    # Executes a command in exec mode on the device.
    #
    # If cache_auto? (on by default) is set then the CLI cache will be flushed.
    #
    # For "show" commands please use show() instead of exec().
    #
    # @param command [String] the exec command to execute
    # @return [String, nil] the body of the output of the exec command
    #   (if any)
    def exec(command) # rubocop:disable Lint/UnusedMethodArgument
      cache_flush if cache_auto?
      # to be implemented by subclasses
    end

    # Executes a "show" command on the device, returning either ASCII or
    # structured output.
    #
    # Unlike config() and exec() this will not clear the CLI cache;
    # multiple calls to the same "show" command may return cached data
    # rather than querying the device repeatedly.
    #
    # @raise [RequestNotSupported] if
    #   structured output is requested but the given command can't provide it.
    # @raise [RequestFailed] if the command is rejected by the device
    #
    # @param command [String] the show command to execute
    # @param type [:ascii, :structured] ASCII or structured output.
    #             Default is :ascii
    # @return [String] the output of the show command, if type == :ascii
    # @return [Hash{String=>String}] key-value pairs, if type == :structured
    def show(command, type=:ascii) # rubocop:disable Lint/UnusedMethodArgument
      # to be implemented by subclasses
    end
  end
end
