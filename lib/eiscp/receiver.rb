# frozen_string_literal: true

require 'resolv'
require_relative './receiver/discovery'
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

    # State object
    attr_accessor :state

    # Receiver's connection socket
    attr_reader :socket
    # Receiver's connection thread
    attr_reader :thread

    # Default connection timeout value in seconds
    DEFAULT_TIMEOUT = 0.5

    # Default Onkyo eISCP port
    ONKYO_PORT = 60_128

    # Create a new EISCP::Receiver object to communicate with a receiver.
    # If no host is given, use auto discovery and create a
    # receiver object using the first host to respond.
    #
    def initialize(host = nil, info_hash = {}, &block)
      # Initialize state
      #
      @state = {}
      # This defines the behavior of CommandMethods by telling it what to do
      # with the Message object that results from a CommandMethod being called.
      # All we're doing here is calling #send_recv
      #
      command_method_proc = proc { |msg| send_recv msg }
      CommandMethods.generate(&command_method_proc)

      # This proc sets the four ECN attributes and initiates a connection to the
      # receiver.
      #
      set_attrs = lambda do |hash|
        @model = hash[:model]
        @port  = hash[:port]
        @area  = hash[:area]
        @mac_address = hash[:mac_address]
        connect(&block) if block_given?
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
      if host.nil?
        first_found = Receiver.discover[0]
        set_host.call first_found.host
        set_attrs.call first_found.ecn_hash
      elsif info_hash.empty?
        set_host.call host
        Receiver.discover.each do |receiver|
          receiver.host == @host && set_attrs.call(receiver.ecn_hash)
        end
      else
        set_host.call host
        set_attrs.call info_hash
      end
    end

    # Manages the thread and uses the same block passed to through #connect.
    #
    def update_thread
      # Kill thread if it exists
      thread && @thread.kill
      @thread = Thread.new do
        loop do
          message = recv
          @state[message.command] = message.value
          yield(message) if block_given?
        end
      end
    end
    private :update_thread

    # This creates a socket conection to the receiver if one doesn't exist,
    # and updates or sets the callback block if one is passed.
    #
    def connect(&block)
      @socket ||= TCPSocket.new(@host, @port)
      update_thread(&block)
    rescue StandardError => e
      puts e
    end

    # Disconnect from the receiver by closing the socket and killing the
    # connection thread.
    #
    def disconnect
      @thread.kill
      @socket.close
    end

    # Sends an EISCP::Message object or string on the network
    #
    def send(eiscp)
      if (@socket.nil? || @socket.closed?) then
        connect
      end
      if eiscp.is_a? EISCP::Message
        @socket.puts(eiscp.to_eiscp)
      elsif eiscp.is_a? String
        @socket.puts eiscp
      end
    end

    # Reads the socket and returns and EISCP::Message
    #
    def recv
      data = String.new
      data << @socket.gets until data.match(/\r\n$/)
      message = Parser.parse(data)
      message
    end

    # Sends an EISCP::Message object or string on the network and returns recieved data string.
    #
    def send_recv(eiscp)
      eiscp = Parser.parse(eiscp) if eiscp.is_a? String
      send eiscp
      sleep DEFAULT_TIMEOUT
      Parser.parse("#{eiscp.command}#{@state[eiscp.command]}")
    end

    # Return ECN hash with model, port, area, and MAC address
    #
    def ecn_hash
      { model: @model,
        port: @port,
        area: @area,
        mac_address: @mac_address }
    end

    # This will return a human-readable represantion of the receiver's state.
    #
    def human_readable_state
      hash = {}
      @state.each do |c, v|
        hash[Dictionary.command_to_name(c).to_s] = (Dictionary.command_value_to_value_name(c, v) || v.to_s).to_s
      end
      hash
    end

    # Runs every command that supports the 'QSTN' value. This is a good way to
    # get the sate of the receiver after connecting.
    #
    def update_state
      Thread.new do
        Dictionary.commands.each do |zone, _commands|
          Dictionary.commands[zone].each do |command, info|
            info[:values].each do |value, _|
              next unless value == 'QSTN'

              send(Parser.parse(command + 'QSTN'))
              # If we send any faster we risk making the stereo drop replies.
              # A dropped reply is not necessarily indicative of the
              # receiver's failure to receive the command and change state
              # accordingly. In this case, we're only making queries, so we do
              # want to capture every reply.
              sleep DEFAULT_TIMEOUT
            end
          end
        end
      end
    end
  end
end
