require_relative '../message'
require_relative './iscp_parser'

module EISCP
  module Parser
    # This module parses an eISCP string and returns a Message object
    #
    module EISCPParser
      def self.parse(string)
        array = string.unpack('A4NNCa3A*')
        msg = ISCPParser.parse(array[5])
        packet = Message.new(
          command: msg.command,
          value: msg.value,
          terminator: msg.terminator,
          unit_type: msg.unit_type,
          start: msg.start
        )
        packet.header = {
          magic: array[0],
          header_size: array[1],
          data_size: array[2],
          version: array[3],
          reserved: array[4]
        }
        packet
      end
    end
  end
end
