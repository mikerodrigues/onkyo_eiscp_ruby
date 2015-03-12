# encoding: utf-8
require_relative './dictionary'
require_relative './parser'

module EISCP
  # The EISCP::Message class is used to handle commands and responses.
  #
  # Messages can be parsed directly from raw data or created with values:
  #   receiver = Receiver.new
  #
  #   command = EISCP::Message.new('PWR', 'QSTN')
  #   response = EISCP::Parser.parse(receiver.send_recv(command))
  #
  class Message
    # EISCP header
    attr_accessor :header
    # ISCP "magic" indicates the start of an eISCP message.
    MAGIC = 'ISCP'
    # eISCP header size, fixed length.
    HEADER_SIZE = 16
    # ISCP protocol version.
    ISCP_VERSION = 1
    # Reserved for future protocol updates.
    RESERVED = "\x00\x00\x00"

    # ISCP Start character, usually "!"
    attr_reader :start
    # ISCP Unit Type character, usually "1"
    attr_reader :unit_type
    # ISCP Command
    attr_reader :command
    # Human readable command name
    attr_reader :command_name
    # Command description
    attr_reader :command_description
    # ISCP Command Value
    attr_reader :value
    # Human readable value name
    attr_reader :value_name
    # Value description
    attr_reader :value_description
    # ISCP Zone
    attr_reader :zone
    # Differentiates parsed messages from command messages
    attr_reader :parsed

    # Terminator character for eISCP packets
    attr_reader :terminator

    # Create an ISCP message
    # @param [String] command three-character length ISCP command
    # @param [String] value variable length ISCP command value
    # @param [String] unit_type_character override default unit type character, optional
    # @param [String] start_character override default start character, optional
    def initialize(command: nil, value: nil, terminator:  "\x1A\x0D\x0A", unit_type: '1', start: '!')
      unless Dictionary.known_command?(command)
        #STDERR.puts "Unknown command #{command}"
      end

      fail 'No value specified.' if value.nil?

      @command = command
      @value = value
      @terminator = terminator
      @unit_type = unit_type
      @start = start
      @header = { magic: MAGIC,
                  header_size:  HEADER_SIZE,
                  data_size: to_iscp.length + @terminator.length,
                  version: ISCP_VERSION,
                  reserved: RESERVED
      }
      begin
        get_human_readable_attrs
      rescue
        #STDERR.puts"Couldn't get all human readable attrs"
      end
    end

    # Check if two messages are equivalent comparing their ISCP messages.
    #
    def ==(other)
      to_iscp == other.to_iscp ? true : false
    end

    # Return ISCP Message string
    #
    def to_iscp
      "#{@start + @unit_type + @command + @value}"
    end

    # Return EISCP Message string
    #
    def to_eiscp
      [
        @header[:magic],
        @header[:header_size].to_i,
        @header[:data_size].to_i,
        @header[:version].to_i,
        @header[:reserved],
        to_iscp.to_s,
        @terminator
      ].pack('A4NNCa3A*A*')
    end

    # Return human readable description.
    #
    def to_s
      "#{@zone} - #{@command_name}:#{@value_name}"
    end

    private

    # Retrieves human readable attributes from the yaml file via Dictionary
    def get_human_readable_attrs
      @zone = Dictionary.zone_from_command(@command)
      @command_name = Dictionary.command_to_name(@command)
      @command_description = Dictionary.description_from_command(@command)
      @value_name = Dictionary.command_value_to_value_name(@command, @value)
      @value_description = Dictionary.description_from_command_value(@command, @value)
    end
  end
end
