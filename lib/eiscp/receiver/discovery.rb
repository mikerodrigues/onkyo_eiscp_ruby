# frozen_string_literal: true

require 'socket'
require_relative '../message'
require_relative '../parser'

module EISCP
  class Receiver
    # This module discovers receivers on the local LAN.
    #
    module Discovery
      # ISCP Magic Packet for Autodiscovery
      ONKYO_MAGIC = Message.new(command: 'ECN', value: 'QSTN', terminator: "\r\n", unit_type: 'x').to_eiscp

      # Populates Receiver attributes with info from ECNQSTN response.
      #
      def ecn_string_to_ecn_array(ecn_string)
        hash = {}
        message = Parser.parse(ecn_string)
        array = message.value.split('/')
        hash[:model] = array.shift
        hash[:port] = array.shift.to_i
        hash[:area] = array.shift
        hash[:mac_address] = array.shift
        hash
      end

      # Returns an array of discovered Receiver objects.
      #
      def discover(discovery_port = Receiver::ONKYO_PORT)
        sock = UDPSocket.new
        sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
        sock.send(ONKYO_MAGIC, 0, '<broadcast>', discovery_port)
        data = []
        loop do
          msg, addr = sock.recvfrom_nonblock(1024)
          data << Receiver.new(addr[2], ecn_string_to_ecn_array(msg))
        rescue IO::WaitReadable
          io = IO.select([sock], nil, nil, 0.5)
          if io.nil?
            return data
          else
            retry
          end
        end
      end
    end
  end
end
