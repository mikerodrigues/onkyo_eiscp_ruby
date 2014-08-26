require 'socket'
require_relative '../message'

module EISCP
  class Receiver
    module Discovery
      # ISCP Magic Packet for Autodiscovery
      ONKYO_MAGIC = Message.new(command: 'ECN', value: 'QSTN', terminator: "\r\n", unit_type: 'x').to_eiscp

      # Populates attrs with info from ECNQSTN response
      #
      def ecn_string_to_ecn_array(ecn_string)
        hash = {}
        message = Message.parse(ecn_string)
        array = message.value.split('/')
        hash[:model] = array.shift
        hash[:port] = array.shift.to_i
        hash[:area] = array.shift
        hash[:mac_address] = array.shift
        hash
      end

      # Returns an array of arrays consisting of a discovery response packet
      # string and the source ip address of the reciever.
      #
      def discover(discovery_port = ONKYO_PORT)
        sock = UDPSocket.new
        sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
        sock.send(ONKYO_MAGIC, 0, '<broadcast>', discovery_port)
        data = []
        loop do

          begin
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
end
