require 'socket'
require_relative './message'
require 'resolv'

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
    # If no host is given, use auto discovery and create a
    # receiver object using the first host to respond.

    def initialize(host = nil, port = ONKYO_PORT)
      if host == nil
        if first_discovered = self.class.discover[0]
          host = first_discovered[1]
          set_info first_discovered[0]
        else
          raise Exception "No receivers discovered."
        end
      end

      # if host given, create object and get info
      @host = Resolv.getaddress host
      @port = port

      # use autodiscovery to get information about receiver unless it was
      # created by discovery above
      unless @model
        begin
          set_info get_ecn
        rescue
          warn "WARNING: Receiver at #{host}:#{port} isn't responding to ECNQSTN discovery."
        end
      end
    end

    # Populates attrs with info from ECNQSTN response
    #
    def set_info(ecn_string)
      array = self.class.parse_ecn(ecn_string)
      @model = array.shift
      @port = array.shift.to_i
      @area = array.shift
      @mac_address = array.shift.split("\x19")[0]
      return self
    end

    # Broadcasts ECNQSTN to get info for the receiver object

    def get_ecn
      self.class.discover.each do |entry|
        if @host == entry[1]
          return entry[0]
        end
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
      message.parameter.split("/")
    end

    # Returns an array of arrays consisting of a discovery response packet string
    # and the source ip address of the reciever.

    def self.discover
      sock = UDPSocket.new
      sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      sock.send(ONKYO_MAGIC, 0, '<broadcast>', ONKYO_PORT)
      data = []
      begin
        msg, addr = sock.recvfrom_nonblock(1024)
        data << [msg, addr[2]]
      rescue IO::WaitReadable
        IO.select([sock], nil, nil, 0.5)
        retry
      end
      return data
    end


    # Internal method for receiving data with a timeout

    def recv(timeout = 0.5)
      sock = TCPSocket.new @host, @port
      begin
        data = sock.recv_nonblock(1024).chomp
      rescue IO::WaitReadable
        IO.select([sock], nil, nil, timeout)
        retry
      end
      return data
      sock.close
    end

    # Sends an EISCP::Message object or string on the network

    def send(eiscp, timeout = 0.5)
      sock = TCPSocket.new @host, @port
      if eiscp.is_a? EISCP::Message
        sock.puts(eiscp.to_eiscp)
      elsif eiscp.is_a? String
        sock.puts eiscp
      end
      sock.close
    end

    # Sends an EISCP::Message object or string on the network and returns recieved data string.

    def send_recv(eiscp, timeout = 0.5)
      sock = TCPSocket.new @host, @port
      if eiscp.is_a? EISCP::Message
        sock.puts(eiscp.to_eiscp)
      elsif eiscp.is_a? String
        sock.puts(eiscp)
      end

      begin
        data = sock.recv_nonblock(1024).chomp
      rescue IO::WaitReadable
        IO.select([sock], nil, nil, timeout)
        retry
      end
      return data
      sock.close
    end

    # Open a TCP connection to the host and print all received messages until
    # killed.

    def connect(&block)
      sock = TCPSocket.new @host, @port
      loop do
        begin
          data = sock.recv_nonblock(1024).chomp
          if block_given?
            yield data
          else
            puts data
          end
        rescue IO::WaitReadable
          IO.select([sock], nil, nil, nil)
          retry
        end
      end

    end

  end
end
