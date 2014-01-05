class ISCPMessage

  # EISCP attrs/constants
  attr_accessor :header
  MAGIC = "ISCP"
  HEADER_SIZE = 16
  VERSION = "\x01"
  RESERVED = "\x00\x00\x00"


  # ISCP attrs
  attr_accessor :start
  attr_accessor :unit_type
  attr_accessor :command
  attr_accessor :parameter


  # REGEX

  def initialize(command, parameter, unit_type = "1", start = "!")
    @unit_type = unit_type
    @start = start
    @command = command
    @parameter = parameter
    @iscp_message = [ @start, @unit_type, @command, @parameter ].inject(:+)
    @header = { :magic => MAGIC, 
                :header_size => HEADER_SIZE, 
                :data_size => @iscp_message.length,
                :version => VERSION, 
                :reserved => RESERVED 
    }

  end

  def self.parse(string)

    # figure out whether you're parsing
    # - iscp msg string '!1PWR01'
    # - eiscp msg string 'ISCP  1!PWR01'
    # - raw command/value 'PWR', '01
    case string
    when /^ISCP/
      puts 'EISCP packet string.'
    when  /(?<start>!)(?<unit_type>\w)(?<command>[A-Z]{3})(?<parameter>\S+)/
      puts 'ISCP message string.'
      match =  string.match(/(?<start>!)(?<unit_type>\w)(?<command>[A-Z]{3})(?<parameter>\S+)/)
      puts match[:command]
    end
  end


  #ISCP Message string parser
  def parse_iscp_message(msg_string)
    match = msg_string.match(/(?<start>!)(?<unit_type>\w)(?<command>[A-Z]{3})(?<parameter>\S+)/)
    ISCPMessage.new(match[:command], match[:parameter], match[:unit_type], match[:start])
  end


  # Return ISCP Message string
  def to_s
    return "#{@start + @unit_type + @command + @parameter}\r"
  end

  # Return EISCP Message string
  def to_eiscp
    return [ @header[:magic], @header[:header_size], @header[:data_size], @header[:version], @header[:reserved], @iscp_message.to_s ].pack("A4NNAa3A*")
  end

  #parse eiscp_message string 
  def parse_eiscp_message(eiscp_message_string)
    array = eiscp_message_string.unpack("A4NNAa3A*")
    iscp_message = ISCPMessage.parse(array[5])
    packet = EISCPPacket.new(iscp_message.command, iscp_message.parameter, iscp_message.unit_type, iscp_message.start)
    packet.header = { 
      :magic => array[0],
      :header_size => array[1],
      :data_size => array[2],
      :version => array[3],
      :reserved => array[4]
    }   
    return packet
  end 

end
