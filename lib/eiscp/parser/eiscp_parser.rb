# frozen_string_literal: true

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
        packet.header = create_header(array)
        packet
      end

      def self.create_header(array)
        {
          magic: array[0],
          header_size: array[1],
          data_size: array[2],
          version: array[3],
          reserved: array[4]
        }
      end

      def self.validate(packet)
        packet.header.header_size.size == packet.command.size
      end
    end

    class EISCPParserException < RuntimeError; end
  end
end
