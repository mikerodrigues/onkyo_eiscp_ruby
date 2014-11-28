require 'resolv'
require 'forwardable'
require_relative './receiver/discovery'
require_relative './receiver/connection'
require_relative './receiver/command_methods'

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
    extend Forwardable
    extend Discovery
    include CommandMethods

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

    # Connection object
    attr_reader:connection

    # Delegate some methods to the @connection object
    def_delegators :@connection, :send, :send_recv, :disconnect, :update_thread, :last, :thread

    # Create a new EISCP object to communicate with a receiver.
    # If no host is given, use auto discovery and create a
    # receiver object using the first host to respond.
    #
    def initialize(host = nil, info_hash = {}, &block)
      # This defines the behavior of CommandMethods by telling it what to do
      # with the Message object that results from a CommandMethod being called.
      # All we're doing here is calling #send_recv
      #
      command_method_proc = Proc.new {|msg| self.send_recv msg}
      CommandMethods.generate(&command_method_proc)
      
      # This proc sets the four ECN attributes and initiates a connection to the
      # receiver.
      #
      set_attrs = lambda do |hash|
        @model = hash[:model]
        @port  = hash[:port]
        @area  = hash[:area]
        @mac_address = hash[:mac_address]
        if block_given?
          connect(&block)
        end
      end

      # This lambda sets the host IP after resolving it
      #
      set_host = lambda do |hostname|
        @host = Resolv.getaddress hostname
      end

      # When no host is given, the first discovered host is returned.
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
          receiver.host == @host && set_attrs.call(receiver.ecn_hash)
        end
      else
        set_host.call host
        set_attrs.call info_hash
      end
    end

    # This method creates a new connection object, initializes CommandMethods,
    # then establishes a connection with the receiver
    def connect(&block)
      @connection = Connection.new
      @connection.connect(@host, @port, &block)
    end

    # Return ECN hash with model, port, area, and MAC address
    #
    def ecn_hash
      { model: @model,
        port: @port,
        area: @area,
        mac_address: @mac_address
      }
    end
  end
end
