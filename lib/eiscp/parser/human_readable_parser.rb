require_relative '../dictionary'

module EISCP
  module Parser
    # This module parses a human readable command and returns a Message object
    #
    module HumanReadableParser
      def self.parse(string)
        array = string.split(' ')

        if Dictionary.zones.include? array[0]
          parsed_zone = array.shift
        else
          parsed_zone = Dictionary::DEFAULT_ZONE
        end 

        command_name = array.shift
        value_name = array.join(" ")
        command = Dictionary.command_name_to_command(command_name, parsed_zone)
        value = Dictionary.command_value_name_to_value(command, value_name)
        if (command.nil? || value.nil?)
          return nil
        end
        Message.new(command: command, value: value)
      end

    end
  end
end
