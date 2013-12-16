require 'socket'
require './eiscp_packet.rb'
require './iscp_message.rb'

class EISCP
  ONKYO_PORT = 60128
  ONKYO_MAGIC = EISCPPacket.new("!xECNQSTN").packet_string

  def initialize(host)
    @host = host
  end

  def discover
    sock = UDPSocket.new
    sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    sock.send(ONKYO_MAGIC, 0, '<broadcast>', '60128')
    5.times do 
      data, client = sock.recvfrom(1024)
      puts data
      puts client
    end
  end

  def send(eiscp_packet)
    sock = UDPSocket.new
    sock.send(eiscp_packet, 0, @host, ONKYO_PORT)
    data = sock.recvfrom(1024)
    puts data
  end

  def connect
    sock = TCPSocket.new @host, 60128
    while line = sock.gets.chomp
      puts line
      puts line.length
      puts '-------------------'
    end
  end

end



