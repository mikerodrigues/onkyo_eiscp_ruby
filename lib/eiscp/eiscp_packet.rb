require 'eiscp/iscp_message'

# Public: Encapsulates ISCP Messages in eISCP packets to send on the network.
# You can alsoe use the class method 'parse' to create objects from strings
# captured from the network using the EISCP class.

class EISCPPacket
  
  MAGIC = "ISCP"
  HEADER_SIZE = 16
  VERSION = "\x01"
  RESERVED = "\x00\x00\x00"

  attr_accessor :header
  attr_reader :iscp_message

  # Create a new EISCPPacket object with a given command and parameter
  # -+command+ - an ISCP command like "PWR" for "system-power"
  # -+parameter+ - an ISCP command parameter like "01" for "on" for 
  # "system-power"
  
  def initialize(command, parameter, unit_type = "1", start = "!")
    @iscp_message = ISCPMessage.new(command, parameter, unit_type, start)
    @header = { :magic => MAGIC, :header_size => HEADER_SIZE, :data_size => @iscp_message.to_s.length, :version => VERSION, :reserved => RESERVED }
  end

  # Returns a raw packet string for sending on the network using EISCP object.

  def to_s
    return [ @header[:magic], @header[:header_size], @header[:data_size], @header[:version], @header[:reserved], @iscp_message.to_s ].pack("A4NNAa3A*")
  end

  # Returns an EISCPPacket from a raw packet string

  def self.parse(eiscp_message_string)
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


