require 'socket'
require 'eiscp/message'

module EISCP
  class Receiver

    attr_accessor :host
    attr_accessor :model
    attr_accessor :port
    attr_accessor :area
    attr_accessor :mac_address

    ONKYO_MAGIC = Message.new("ECN", "QSTN", "x").to_eiscp
    ONKYO_PORT = 60128
    # Create a new EISCP object to communicate with a receiver.

    def initialize(host, port = ONKYO_PORT)
      @host = host
      @port = port
    end
    
    # Populates @model, @port, @area, @mac_address
    # Uses #get_ecn to get parsed ECNQSTN response
    # Returns self with updated attrs
    
    def get_info
      if array = self.get_ecn_array
        @model = array[0]
        @port = array[1].to_i
        @area = array[2]
        @mac_address = array[3]
        return self
      end 
    end
    
    # Gets the ECNQSTN response of self using @host
    # then parses it with parse_ecn, returning an array
    # with receiver info

    def get_ecn_array
      self.class.discover.each do |entry|
        if @host == entry[1]
          array = self.class.parse_ecn(entry[0])
        end
        return array
      end
    end

    # Returns array containing @model, @port, @area, and @mac_address
    # from ECNQSTN response

    def self.parse_ecn(ecn_string)
      message = EISCP::Message.parse(ecn_string)
      message_array = message.parameter.split("/")
    end

    # Internal method for receiving data with a timeout

    def self.recv(sock, timeout = 0.5)
      data = []
      while true
        ready = IO.select([sock], nil, nil, timeout)
        if ready != nil
          then readable = ready[0]
        else
          return data
        end


        readable.each do |socket|
          begin
            if socket == sock
              data << sock.recv_nonblock(1024).chomp
            end
          rescue IO::WaitReadable
            retry
          end
        end

      end
    end

    # Returns an array of arrays consisting of a discovery response packet string
    # and the source ip address of the reciever.

    def self.discover
      sock = UDPSocket.new
      sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      sock.send(ONKYO_MAGIC, 0, '<broadcast>', ONKYO_PORT)
      data = []
      while true
        ready = IO.select([sock], nil, nil, 0.5)
        if ready != nil
          then readable = ready[0]
        else
          return data
        end


        readable.each do |socket|
          begin
            if socket == sock
              msg, addr = sock.recvfrom_nonblock(1024)
              data << [msg, addr[2]]
            end
          rescue IO::WaitReadable
            retry
          end
        end

      end
    end

    # Sends a packet string on the network

    def send(eiscp_packet)
      sock = TCPSocket.new @host, @port
      sock.puts eiscp_packet
      sock.close
    end

    # Send a packet string and return recieved data string.

    def send_recv(eiscp_packet)
      sock = TCPSocket.new @host, @port
      sock.puts eiscp_packet
      return Receiver.recv(sock, 0.5)
    end

    # Open a TCP connection to the host and print all received messages until
    # killed.

    def connect(&block)
      sock = TCPSocket.new @host, @port
      while true
        ready = IO.select([sock], nil, nil, nil)
        if ready != nil
          then readable = ready[0]
        else
          return
        end

        readable.each do |socket|
          begin
            if socket == sock
              data = sock.recv_nonblock(1024).chomp
              if block_given?
                yield data
              else
                puts data
              end
            end
          rescue IO::WaitReadable
            retry
          end
        end

      end
    end

  end
end
