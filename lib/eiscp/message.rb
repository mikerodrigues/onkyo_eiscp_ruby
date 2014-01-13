module EISCP
  class Message

    # EISCP header
    attr_accessor :header
    MAGIC = "ISCP"
    HEADER_SIZE = 16
    ISCP_VERSION = "\x01"
    RESERVED = "\x00\x00\x00"


    # ISCP attrs
    attr_accessor :start
    attr_accessor :unit_type
    attr_accessor :command
    attr_accessor :parameter
    attr_reader   :iscp_message


    # REGEX
    REGEX = /(?<start>!)?(?<unit_type>(\d|x))?(?<command>[A-Z]{3})\s?(?<parameter>.*)(?<end>(\x0D|\x0A|\x1A))?/

    def initialize(command, parameter, unit_type = "1", start = "!")
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
      @parameter = parameter
      @iscp_message = [ @start, @unit_type, @command, @parameter ].inject(:+)
      @header = { :magic => MAGIC, 
                  :header_size => HEADER_SIZE, 
                  :data_size => @iscp_message.length,
                  :version => ISCP_VERSION, 
                  :reserved => RESERVED 
      }
    end


    # Identifies message format, calls appropriate parse function
    # returns Message object.

    def self.parse(string)
      case string
      when /^ISCP/
        parse_eiscp_string(string)
      when REGEX
        parse_iscp_message(string)
      else
        puts "Not a valid ISCP or EISCP message."
      end
    end



    # ISCP Message string parser

    def self.parse_iscp_message(msg_string)
      match = msg_string.match(REGEX)
      Message.new(match[:command], match[:parameter], match[:unit_type], match[:start])
    end

    #parse eiscp_message string 
    def self.parse_eiscp_string(eiscp_message_string)
      array = eiscp_message_string.unpack("A4NNAa3A*")
      iscp_message = Message.parse_iscp_message(array[5])
      packet = Message.new(iscp_message.command, iscp_message.parameter, iscp_message.unit_type, iscp_message.start)
      packet.header = { 
        :magic => array[0],
        :header_size => array[1],
        :data_size => array[2],
        :version => array[3],
        :reserved => array[4]
      }   
      return packet
    end

    # Return ISCP Message string
    def to_iscp
      return "#{@start + @unit_type + @command + @parameter}"
    end

    # Return EISCP Message string
    def to_eiscp
      return [ @header[:magic], @header[:header_size], @header[:data_size], @header[:version], @header[:reserved], @iscp_message.to_s ].pack("A4NNAa3A*")
    end

  end
end
