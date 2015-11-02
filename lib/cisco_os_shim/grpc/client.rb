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

require 'cisco_os_shim'
require 'grpc'
require 'json'
require_relative 'ems_services'
require_relative 'client_errors'

include IOSXRExtensibleManagabilityService
include CiscoLogger

module Cisco::Shim::GRPC
  # Client implementation using gRPC API for IOS XR
  class Client < Cisco::Shim::Client
    Cisco::Shim.register_client(self)

    def initialize(address, username, password)
      # TODO: remove if/when we have a local socket to use
      if address.nil? && ENV['NODE']
        address ||= ENV['NODE'].split(' ')[0]
        username ||= ENV['NODE'].split(' ')[1]
        password ||= ENV['NODE'].split(' ')[2]
      end
      super(address, username, password)
      @update_metadata = proc do |md|
        md[:username] = username
        md[:password] = password
        md
      end
      @config = GRPCConfigOper::Stub.new(address,
                                         update_metadata: @update_metadata)
      @exec = GRPCExec::Stub.new(address,
                                 update_metadata: @update_metadata)

      # Make sure we can actually connect
      show('show clock')
    end

    def validate_args(address, username, password)
      super
      fail TypeError, 'address must be specified' if address.nil?
      fail ArgumentError, 'port # required in address' unless address[/:/]
      # Connection to remote system - username and password are required
      fail TypeError, 'username must be specified' if username.nil?
      fail TypeError, 'password must be specified' if password.nil?
    end

    def supports?(api)
      (api == :cli)
    end

    def cache_flush
      @cache_hash = {
        'cli_config'           => {},
        'show_cmd_text_output' => {},
        'show_cmd_json_output' => {},
      }
    end

    # Configure the given command(s) on the device.
    def config(commands)
      super
      commands = commands.join("\n") if commands.is_a?(Array)
      args = CliConfigArgs.new(cli: commands)
      req(@config, 'cli_config', args)
    end

    def exec(command)
      super
      args = ShowCmdArgs.new(cli: command)
      req(@exec, 'show_cmd_text_output', args)
    end

    def show(command, type=:ascii)
      super
      args = ShowCmdArgs.new(cli: command)
      fail TypeError unless type == :ascii || type == :structured
      req(@exec,
          type == :ascii ? 'show_cmd_text_output' : 'show_cmd_json_output',
          args)
    end

    def req(stub, type, args)
      if cache_enable? && @cache_hash[type] && @cache_hash[type][args.cli]
        return @cache_hash[type][args.cli]
      end

      debug "Sending '#{type}' request with args: '#{args}'"
      response = stub.send(type, args)
      output = ''
      if response.kind_of?(Enumerator)
        output = response.map { |reply| handle_reply(type, reply) }
        output = output[0] if output.length == 1
      else
        output = handle_reply(type, response)
      end

      @cache_hash[type][args.cli] = output if cache_enable? && !output.empty?
      return output
    rescue GRPC::BadStatus => e
      case e.code
      when GRPC::Core::StatusCodes::UNAVAILABLE
        raise Cisco::Shim::ConnectionRefused, e.details
      when GRPC::Core::StatusCodes::UNAUTHENTICATED
        raise Cisco::Shim::AuthenticationFailed, e.details
      else
        raise
      end
    end
    private :req

    def handle_reply(type, reply)
      debug "Handling '#{type}' reply:\n#{reply}"
      if reply.errors.empty?
        output = ''
        if type == 'show_cmd_text_output'
          # The output begins with \n<command>\n
          # which we don't really need. Discard it.
          output = reply.output.split("\n")[2..-1].join("\n")
        elsif type == 'show_cmd_json_output'
          output = reply.jsonoutput
        end
        debug "Success with output:\n#{output}"
        return output
      end
      debug "Reply includes errors:\n#{reply.errors}"
      # Conveniently for us, all *Reply protobufs in EMS have an errors field
      # Less conveniently, some are JSON and some are not.
      if type == 'cli_config'
        # {
        #   "cisco-grpc:errors": {
        #   "error": [
        #     {
        #       "error-type": "application",
        #       "error-tag": "operation-failed",
        #       "error-severity": "error",
        #       "error-message": "....",
        #     },
        #     {
        #       ...
        msg = JSON.parse(reply.errors)
        msg = msg['cisco-grpc:errors']['error']
        msg = msg.map { |m| m['error-message'] }
        fail CliError.new(msg, 'input TODO')
      else
        fail CliError.new(reply.errors, 'input TODO')
      end
    end
    private :handle_reply
  end
end
