require 'socket'
require 'eiscp'

# Mock server that only responds to ECNQSTN.

class EISCPServer

  ONKYO_DISCOVERY_RESPONSE =  EISCPPacket.new("ECN", "TX-NR609/60128/DX/001122334455")

  def initialize
    Socket.udp_server_loop("255.255.255.255", 60128) do |msg, msg_src|
      msg_src.reply ONKYO_DISCOVERY_RESPONSE
      puts msg
    end
  end
end

EISCPServer.new

