require 'socket'
require 'eiscp/eiscp_packet.rb'
require 'eiscp/iscp_message.rb'

class EISCP
  ONKYO_PORT = 60128
  ONKYO_MAGIC = EISCPPacket.new("!xECNQSTN").packet_string

  def initialize(host)
    @host = host
  end

  def self.discover
    sock = UDPSocket.new
    sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    sock.send(ONKYO_MAGIC, 0, '<broadcast>', ONKYO_PORT)
    data = []
    while true
      ready = IO.select([sock], nil, nil, 0.5)
      if ready != nil
        then readable = ready[0]
      else
        return data
      end


      readable.each do |socket|
        begin
          if socket == sock
            data << sock.recv_nonblock(1024)
          end
        rescue
          retry
        end
      end

    end
  end

  def send(eiscp_packet)
    sock = TCPSocket.new @host, ONKYO_PORT
    sock.puts eiscp_packet
    while line = sock.gets.chomp
      if line == nil
        puts line
        puts line.length
        puts '---------------'
      end
    end
  end

  def recv
  end


  def connect
    sock = TCPSocket.new @host, ONKYO_PORT
    buffer = ""
    while line = sock.gets.chomp
      buffer += line
      puts buffer.split "\r"

    end
  end


end



