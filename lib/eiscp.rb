# Create and send EISCP messages to control Onkyo receivers.

class EISCP
  VERSION = '0.0.2'
end

require 'eiscp/eiscp'
require 'eiscp/eiscp_packet'
require 'eiscp/iscp_message'
require 'eiscp/command'
