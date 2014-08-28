require_relative './parser'
require_relative './dictionary'

module EISCP
  # Iterates through every available command and defines a method to call that
  # command. It's intended to be used through Receiver and uses methods included
  # by Receiver::Connection. Each method accepts a string that should match the
  # human readable name of a valid value for that command.
  #
  module CommandMethods
    Dictionary.zones.each do |zone|
      Dictionary.commands[zone].each do |command, _values|
        begin
          command_name = Dictionary.command_to_name(command).to_s.gsub(/-/, '_')
          define_method(command_name) do |v|
            send_recv Parser.parse(command_name.gsub(/_/, '-') + ' ' + v)
          end
        rescue => e
          puts e
        end
      end
    end
  end
end

