require_relative '../message'
require_relative '../dictionary'

module EISCP
  module Parser
    # This module parses a human readable command and returns a Message object
    #
    module HumanReadableParser
      def self.parse(string)
        array = string.split(' ')
        zone = Dictionary::DEFAULT_ZONE
        command_name = ''
        value_name = ''
        if array.count == 3
          zone = array.shift
          command_name = array.shift
          value_name = array.shift
        elsif array.count == 2
          command_name = array.shift
          value_name = array.shift
        end
        command = Dictionary.command_name_to_command(command_name, zone)
        value = Dictionary.command_value_name_to_value(command, value_name)
        Message.new(command: command, value: value)
      end
    end
  end
end
