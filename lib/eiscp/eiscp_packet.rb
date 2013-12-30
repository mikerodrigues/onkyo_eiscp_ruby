require 'eiscp/iscp_message'

class EISCPPacket
  
  MAGIC = "ISCP"
  HEADER_SIZE = 16
  VERSION = "\x01"
  RESERVED = "\x00\x00\x00"

  attr_accessor :header
  attr_reader :iscp_message

  def initialize(*args)
    @iscp_message = ISCPMessage.new(*args) 
    @header = { :magic => MAGIC, :header_size => HEADER_SIZE, :data_size => @iscp_message.to_s.length, :version => VERSION, :reserved => RESERVED }
  end

  def to_s
    return [ @header[:magic], @header[:header_size], @header[:data_size], @header[:version], @header[:reserved], @iscp_message.to_s ].pack("A4NNAA3A*")
  end

  def self.parse(eiscp_message_string)
    array = eiscp_message_string.unpack("A4NNAA3A*")
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


