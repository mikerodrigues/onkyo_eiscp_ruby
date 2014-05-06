require 'socket'
require_relative './message'
require_relative './command'
require 'resolv'
require 'pry'

module EISCP
  # The EISCP::Receiver class is used to communicate with one or more
  # receivers the network. A Receiver can be instantiated automatically
  # using discovery, or by hostname and port.
  #
  #   receiver = EISCP::Receiver.new # find first receiver on LAN
  #   receiver = EISCP::Receiver.new('192.168.1.12') # default port
  #   receiver = EISCP::Receiver.new('192.168.1.12', 60129) # non standard port
  #
  class Receiver
    attr_accessor :host
    attr_accessor :model
    attr_accessor :port
    attr_accessor :area
    attr_accessor :mac_address

    ONKYO_MAGIC = Message.new('ECN', 'QSTN', 'x').to_eiscp
    ONKYO_PORT = 60_128

    # Create a new EISCP object to communicate with a receiver.
    # If no host is given, use auto discovery and create a
    # receiver object using the first host to respond.
    #
    def initialize(host = nil, hash = {})
      # if no host argument is given, get first receiver objet returned from
      # Receiver.discover 
      if host.nil?
        return Receiver.discover[0]
      end


      # if host is given, set host
      @host = Resolv.getaddress host

      if hash.empty?
        Receiver.discover.each do |receiver|
          if receiver.host == @host
            return receiver
          end
        end
      end
      @model = hash[:model]
      @port  = hash[:port]
      @area  = hash[:area]
      @mac_address = hash[:mac_address]
    end

    # Populates attrs with info from ECNQSTN response
    #
    def self.ecn_string_to_ecn_array(ecn_string)
      hash = {}
      array = Receiver.parse_ecn(ecn_string)
      hash[:model] = array.shift
      hash[:port] = array.shift.to_i
      hash[:area] = array.shift
      hash[:mac_address] = array.shift.split("\x19")[0]
      return hash
    end

    # Returns array containing @model, @port, @area, and @mac_address
    # from ECNQSTN response
    #
    def self.parse_ecn(ecn_string)
      message = EISCP::Message.parse(ecn_string)
      message.value.split('/')
    end

    # Returns an array of arrays consisting of a discovery response packet
    # string and the source ip address of the reciever.
    #
    def self.discover
      sock = UDPSocket.new
      sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      sock.send(ONKYO_MAGIC, 0, '<broadcast>', ONKYO_PORT)
      data = []
      loop do
     
        begin
          msg, addr = sock.recvfrom_nonblock(1024)
          data << Receiver.new(addr[2], ecn_string_to_ecn_array(msg))
        rescue IO::WaitReadable
          io = IO.select([sock], nil, nil, 0.5)
          puts io
          if io == nil
            return data
          else
            retry
          end
        end

      end
    end

    # Internal method for receiving data with a timeout
    #
    def recv(timeout = 0.5)
      TCPSocket.open(@host, @port) do |sock|
        begin
          data = sock.recv_nonblock(1024).chomp
        rescue IO::WaitReadable
          IO.select([sock], nil, nil, timeout)
          retry
        end
        return data
      end
    end

    # Sends an EISCP::Message object or string on the network
    #
    def send(eiscp, timeout = 0.5)
      TCPSocket.open(@host, @port) do |sock|
        if eiscp.is_a? EISCP::Message
          sock.puts(eiscp.to_eiscp)
        elsif eiscp.is_a? String
          sock.puts eiscp
        end
      end
    end

    # Sends an EISCP::Message object or string on the network and returns recieved data string.
    #
    def send_recv(eiscp, timeout = 0.5)
      TCPSocket.open(@host, @port) do |sock|
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
      end
    end

    # Open a TCP connection to the host and print all received messages until
    # killed.
    #
    def connect(&block)
      TCPSocket.open(@host, @port) do |sock|
        loop do
          begin
            data = Message.parse(sock.recv_nonblock(1024).chomp)
            if block_given?
              yield data
            else
              puts data.to_s
            end
          rescue IO::WaitReadable
            IO.select([sock], nil, nil, nil)
            retry
          end
        end
      end
    end

    def method_missing(sym, *args, &block)
      command_name = sym.to_s.gsub(/_/, "-")
      value_name = args[0].to_s.gsub(/_/, "-")
      begin
        send_recv EISCP::Command.parse(command_name + " " + value_name)
      rescue
        puts "Could not find a command: #{command_name} with args #{value_name} and block #{block}"
      end
    end
  end
end
