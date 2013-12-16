class EISCPPacket
  Header= Struct.new(:magic, :header_size, :data_size, :version, :reserved)
  MAGIC = "ISCP"
  HEADER_SIZE = 16
  VERSION = "\x01"
  RESERVED = "\x00\x00\x00"

  attr_reader :packet_string

  def initialize(iscp_message_string)
    @packet_string = ['ISCP', HEADER_SIZE, iscp_message_string.length, VERSION, RESERVED, iscp_message_string ].pack("A4NNAA3A*")
  end

  def self.parse(eiscp_message_string)
    eiscp_message_string.unpack("A4NNAA3A*")
  end

end


