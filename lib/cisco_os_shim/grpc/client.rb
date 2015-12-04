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

require_relative '../core/client'
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
      @platform = :ios_xr

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

      debug "Sending '#{type}' request:"
      if args.is_a?(ShowCmdArgs) || args.is_a?(CliConfigArgs)
        debug "  with cli: '#{args.cli}'"
      end
      response = stub.send(type, args)
      output = ''
      if response.kind_of?(Enumerator)
        output = response.map { |reply| handle_reply(args, reply) }
        output = output[0] if output.length == 1
      else
        output = handle_reply(args, response)
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

    def handle_reply(args, reply)
      debug "Handling '#{reply.class}' reply:"
      debug "  output: #{reply.output}" if reply.is_a?(ShowCmdTextReply)
      debug "  jsonoutput: #{reply.jsonoutput}" if reply.is_a?(ShowCmdJSONReply)
      if reply.errors.empty?
        debug "  errors: '#{reply.errors}'"
        output = ''
        if reply.is_a?(ShowCmdTextReply)
          output = handle_text_output(args, reply.output)
        elsif reply.is_a?(ShowCmdJSONReply)
          output = reply.jsonoutput
        end
        debug "Success with output:\n#{output}"
        return output
      end
      debug "Reply includes errors:\n#{reply.errors}"
      # Conveniently for us, all *Reply protobufs in EMS have an errors field
      # Less conveniently, some are JSON and some are not.
      if reply.is_a?(CliConfigReply)
        handle_cli_config_error(reply)
      elsif /^Disallowed commands:/ =~ reply.errors
        fail Cisco::Shim::RequestNotSupported, reply.errors
      else
        fail CliError.new(reply.errors, args.cli)
      end
    end
    private :handle_reply

    def handle_text_output(args, output)
      # For a successful show command, gRPC presents the output as:
      # \n--------- <cmd> ----------
      # \n<output of command>
      # \n\n

      # For an invalid CLI, gRPC presents the output as:
      # \n--------- <cmd> --------
      # \n<cmd>
      # \n<error output>
      # \n\n

      # Discard the leading whitespace, header, and trailing whitespace
      output = output.split("\n").drop(2)
      return '' if output.nil? || output.empty?

      # Now we have either [<output_line_1>, <output_line_2>, ...] or
      # [<cmd>, <error_line_1>, <error_line_2>, ...]
      if output[0].strip == args.cli.strip
        fail CliError.new(output.join("\n"), args.cli)
      end
      output.join("\n")
    end
    private :handle_text_output

    # Generate a CliError from a failed CliConfigReply
    def handle_cli_config_error(reply)
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
      # Example msg:
      # !! SYNTAX/AUTHORIZATION ERRORS: This configuration failed due to
      # !! one or more of the following reasons:
      # !!  - the entered commands do not exist,
      # !!  - the entered commands have errors in their syntax,
      # !!  - the software packages containing the commands are not active,
      # !!  - the current user is not a member of a task-group that has
      # !!    permissions to use the commands.
      #
      # foo
      # bar
      #
      rejected = msg.map do |m|
        match = /\n\n(.*)\n\n\Z/m.match(m)
        if match.nil?
          '(see message)'
        else
          match[1].split("\n")
        end
      end
      rejected.flatten!
      msg = msg[0] if msg.length == 1
      fail CliError.new(msg, rejected)
    end
    private :handle_cli_config_error
  end
end
