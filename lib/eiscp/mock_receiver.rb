require 'socket'
require 'eiscp/receiver'
require 'eiscp/message'

# Mock server that only responds to ECNQSTN.

module EISCP
  class MockReceiver

    ONKYO_DISCOVERY_RESPONSE =  Message.new("ECN", "TX-NR609/60128/DX/001122334455")

    # Create/start the server object.

    def initialize
      Socket.udp_server_loop("255.255.255.255", EISCP::ONKYO_PORT) do |msg, msg_src|
        msg_src.reply ONKYO_DISCOVERY_RESPONSE.to_eiscp
        puts msg
      end
    end

  end
end
