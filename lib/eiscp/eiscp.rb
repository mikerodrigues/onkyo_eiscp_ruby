require 'socket'
require 'eiscp/eiscp'

class EISCP
  ONKYO_PORT = 60128
  @onkyo_magic = EISCP.new("ECN", "QSTN", "x").to_eiscp

  # Create a new EISCP object to communicate with a receiver.

  def initialize(host)
    @host = host
  end

  # Internal method for receiving data with a timeout

  def self.recv(sock, timeout = 0.5)
    data = []
    while true
      ready = IO.select([sock], nil, nil, timeout)
      if ready != nil
        then readable = ready[0]
      else
        return data
      end


      readable.each do |socket|
        begin
          if socket == sock
            data << sock.recv_nonblock(1024).chomp
          end
        rescue IO::WaitReadable
          retry
        end
      end

    end
  end
  
  # Returns an array of arrays consisting of a discovery response packet string
  # and the source ip address of the reciever.

  def self.discover
    sock = UDPSocket.new
    sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    sock.send(@onkyo_magic, 0, '<broadcast>', ONKYO_PORT)
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
            msg, addr = sock.recvfrom_nonblock(1024)
            data << [msg, addr[2]]
          end
        rescue IO::WaitReadable
          retry
        end
      end

    end
  end
  
  # Sends a packet string on the network

  def send(eiscp_packet)
    sock = TCPSocket.new @host, ONKYO_PORT
    sock.puts eiscp_packet
    sock.close
  end

  # Send a packet string and return recieved data string.
  
  def send_recv(eiscp_packet)
    sock = TCPSocket.new @host, ONKYO_PORT
    sock.puts eiscp_packet
    puts EISCP.recv(sock, 0.5)
  end

  # Open a TCP connection to the host and print all received messages until
  # killed.

  def connect(&block)
    sock = TCPSocket.new @host, ONKYO_PORT
    while true
      ready = IO.select([sock], nil, nil, nil)
      if ready != nil
        then readable = ready[0]
      else
        return
      end

      readable.each do |socket|
        begin
          if socket == sock
            data = sock.recv_nonblock(1024).chomp
            if block_given?
              yield data
            else
              puts data
            end
          end
        rescue IO::WaitReadable
          retry
        end
      end

    end
  end

end






