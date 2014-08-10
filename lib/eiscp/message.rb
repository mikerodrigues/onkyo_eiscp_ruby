# encoding: utf-8
require_relative './dictionary'

module EISCP
  # The EISCP::Message class is used to handle commands and responses.
  #
  # Messages can be parsed directly from raw data or created with values:
  #   receiver = Receiver.new
  #
  #   command = EISCP::Message.new('PWR', 'QSTN')
  #   response = EISCP::Message.parse(receiver.send_recv(command))
  #
  class Message
    

    extend Dictionary

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
    # Full ISCP Message
    attr_reader :iscp_message
    # ISCP Zone
    attr_reader :zone
    # Differentiates parsed messages from command messages
    attr_reader :parsed

    # Terminator character for eISCP packets
    attr_reader :terminator

    # Regexp for parsing ISCP messages
    REGEX = /(?<start>!)?(?<unit_type>(\d|x))?(?<command>[A-Z]{3})\s?(?<value>.*?)(?<terminator>[[:cntrl:]]*$)/

    # Create an ISCP message
    # @param [String] command three-character length ISCP command
    # @param [String] value variable length ISCP command value
    # @param [String] unit_type_character override default unit type character, optional
    # @param [String] start_character override default start character, optional
    def initialize(command, value, terminator = "\r\n", unit_type = '1', start = '!')
      # A really stupid hack so that I don't have to figure out which attrs are
      # being passed to #new from an array where some attrs are 'nil'.
      #
      if terminator == ""
        @terminator = "\r\n"
      else
        @terminator = terminator
      end
      if unit_type == nil
        @unit_type = "1"
      else
        @unit_type = unit_type
      end
      if start == nil
        @start = "!"
      else
        @start = start
      end

      @command = command
      @value = value
      @iscp_message = [@start, @unit_type, @command, @value].inject(:+)
      @header = { magic: MAGIC,
                  header_size:  HEADER_SIZE,
                  data_size: @iscp_message.length,
                  version: ISCP_VERSION,
                  reserved: RESERVED
      }
      get_human_readable_attrs
    end

    # Check if two messages are equivalent comparing their ISCP messages.
    #
    def ==(other)
      iscp_message == other.iscp_message ? true : false
    end

    # Identifies message format, calls appropriate parse function
    # returns Message object.
    #
    def self.parse(string)
      case string
      when /^ISCP/
        parse_eiscp_string(string)
      when REGEX
        parse_iscp_message(string)
      else
        parse_human_readable(string)
      end
    end

    # Human readable command parser
    def self.parse_human_readable(string)
      array = string.split(" ")
      zone = Dictionary::DEFAULT_ZONE
      command_name = ''
      value_name = ''
      if array.count == 3
        zone = array.shift
        command_name = array.shift
        value_name = array.shift
      elsif array.count == 2
        command_name = array.shift
        value_name = array.shift
      end
        command = command_name_to_command(command_name)
        value = command_value_name_to_value(command, value_name)
        return new(command, value)
    end

    # ISCP Message string parser
    #
    def self.parse_iscp_message(msg_string)
      match = msg_string.match(REGEX)
      new(match[:command], match[:value], match[:terminator], match[:unit_type], match[:start])
    end

    # Parse eiscp_message string
    #
    def self.parse_eiscp_string(eiscp_message_string)
      array = eiscp_message_string.unpack('A4NNCa3A*')
      msg = parse_iscp_message(array[5])
      packet = new(msg.command, msg.value, msg.terminator, msg.unit_type, msg.start)
      packet.header = {
        magic: array[0],
        header_size: array[1],
        data_size: array[2],
        version: array[3],
        reserved: array[4]
      }
      return packet
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
        @iscp_message.to_s,
        @terminator
      ].pack('A4NNCa3A*A*')
    end

    # Return human readable description.
    #
    def to_s
      puts "#{@zone} - #{@command_name}:#{@value_name}"
    end

    private

    # Retrieves human readable attributes from the yaml file via Dictionary
    def get_human_readable_attrs
      begin
        @zone = zone_from_command(@command)
        @command_name = command_to_name(@command)
        @command_description = description_from_command(@command)
        @value_name = command_value_to_value_name(@command, @value)
        @value_description = description_from_command_value(@command, @value)
      rescue
        # "Error getting human readable attrs for #{@zone} - #{@command}:#{@value}"
      end
    end
  end
end
