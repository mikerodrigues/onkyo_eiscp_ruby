require 'socket'
require_relative './message'
require_relative './dictionary'
require 'resolv'

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
    # Receiver's IP address
    attr_accessor :host
    # Receiver's model string
    attr_accessor :model
    # Receiver's ISCP port
    attr_accessor :port
    # Receiver's region
    attr_accessor :area
    # Receiver's MAC address
    attr_accessor :mac_address

    # Receiver's connection socket
    attr_reader :socket
    # Receiver's connection thread
    attr_reader :thread
    # Receiver's message response queue
    attr_reader :queue
    # Most recent message received
    attr_reader :last

    # ISCP Magic Packet for Autodiscovery
    ONKYO_MAGIC = Message.new(command: 'ECN', value: 'QSTN', terminator: "\r\n", unit_type: 'x').to_eiscp
    # Default Onkyo eISCP port
    ONKYO_PORT = 60_128

    # Create a new EISCP object to communicate with a receiver.
    # If no host is given, use auto discovery and create a
    # receiver object using the first host to respond.
    #
    def initialize(host = nil, info_hash = {}, &block)
      # This proc sets the four ECN attributes and returns the object
      #
      set_attrs = lambda do |hash|
        @model = hash[:model]
        @port  = hash[:port]
        @area  = hash[:area]
        @mac_address = hash[:mac_address]
        @socket = TCPSocket.new(@host, @port)
      end

      # This lambda sets the host IP after resolving it
      set_host = lambda do |hostname|
        @host = Resolv.getaddress hostname
      end

      # When no host is give, the first discovered host is returned.
      # 
      # When a host is given without a hash ::discover will be used to find
      # a receiver that matches.
      #
      # Else, use the given host and hash to create a new Receiver object.
      # This is how ::discover creates Receivers.
      #
      case
      when host.nil?
        first_found = Receiver.discover[0]
        set_host.call first_found.host
        set_attrs.call first_found.ecn_hash
      when info_hash.empty?
        set_host.call host
        Receiver.discover.each do |receiver|
          if receiver.host == @host
            set_attrs.call receiver.ecn_hash
          end
        end
      else
        set_host.call host
        set_attrs.call info_hash
      end

      # This handles the background thread for monitoring messages from the
      # receiver.
      #
      # If a block is given, it can be used to setup a callback when a message
      # is received.
      #
      if block_given?
        @thread = Thread.new do 
          while true
            msg = recv
            @last = msg
            block.call(msg)
          end
        end
      else
        @queue = Queue.new
        @thread = Thread.new do
          while true
            msg = recv
            @queue << msg
            @last = msg
          end
        end
      end
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
      hash[:mac_address] = array.shift
      hash
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
          if io.nil?
            return data
          else
            retry
          end
        end

      end
    end

    # Sends an EISCP::Message object or string on the network
    #
    def send(eiscp, timeout = 0.5)
      if eiscp.is_a? EISCP::Message
        @socket.puts(eiscp.to_eiscp)
      elsif eiscp.is_a? String
        if Message.parse eiscp
          @socket.puts eiscp
        else
          fail
        end
      end
    end

    def recv(timeout = 0.5)
      mesg_str = ''
      until mesg_str.match(/\r\n$/)
        mesg_str << @socket.gets
      end
      Message.parse mesg_str
    end

    # Sends an EISCP::Message object or string on the network and returns
    # recieved data string.
    #
    def send_recv(eiscp, timeout = 0.5)
      if eiscp.is_a? EISCP::Message
        @socket.puts(eiscp.to_eiscp)
      elsif eiscp.is_a? String
        if Message.parse eiscp
          @socket.puts(eiscp)
        else
          fail
        end
      end
      sleep 0.1
      @last
    end

    # Open a TCP connection to the host and print all received messages until
    # killed.
    #
    def connect(&block)
      loop do
        data = recv
        if block_given?
          yield data
        else
          puts data.to_s
        end
      end
    end

    # Return ECN array with model, port, area, and MAC address
    #
    def ecn_hash
      { model: @model,
        port: @port,
        area: @area,
        mac_address: @mac_address
      }
    end

    # Catch any missing methods and treat the method name as the human-readable
    # command name while treating the argument as a human-readable value name.
    #
    def method_missing(sym, *args, &block)
      command_name = sym.to_s.gsub(/_/, '-')
      value_name = args[0].to_s.gsub(/_/, '-')
      begin
        send_recv EISCP::Message.parse(command_name + ' ' + value_name)
      rescue
        puts "Could not find a command: #{command_name} with args #{value_name} and block #{block}"
      end
    end
  end
end
