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

      # This proc sets the four ECN attributes and returns the object
      #
      set_attrs = Proc.new do |hash|
        @model = hash[:model]
        @port  = hash[:port]
        @area  = hash[:area]
        @mac_address = hash[:mac_address]
        return
      end
      
      # This lambda sets the host IP after resolving it
      set_host = lambda do |host|
        @host = Resolv.getaddress host
      end

      # if no host argument is given, find a recceiver with matching IP and copy
      # its ECN attributes. Copying is done because a separate object can not be
      # the return value of #initialize
      #
      if host.nil?
        first_found = Receiver.discover[0]
        set_host.call first_found.host
        set_attrs.call first_found.ecn_hash
      end

      # if a host is given, but no hash, find matching receiver and copy ECN
      # attreibutes
      #
      if hash.empty?
        set_host.call host
        Receiver.discover.each do |receiver|
          if receiver.host == @host
            set_attrs.call receiver.ecn_hash
          end
        end
      end
      
      # this will only run if a hash and host are present
      #
      set_host.call host
      set_attrs.call hash
    end

    # Populates attrs with info from ECNQSTN response
    #
    def self.ecn_string_to_ecn_array(ecn_string)
      hash = {}
      message = EISCP::Message.parse(ecn_string)
      array = message.value.split('/')
      hash[:model] = array.shift
      hash[:port] = array.shift.to_i
      hash[:area] = array.shift
      hash[:mac_address] = array.shift.split("\x19")[0]
      return hash
    end

    # Returns an array of arrays consisting of a discovery response packet
    # string and the source ip address of the reciever.
    #
    def self.discover(discovery_port = ONKYO_PORT)
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

    # Return ECN array with model, port, area, and MAC address
    #
    def ecn_hash
      return {:model => @model, :port => @port, :area => @area, :mac_address => @mac_address}
    end
    
    # Catch any missing methods and treat the method name as the human-readable
    # command name while treating the argument as a human-readable value name.
    #
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
