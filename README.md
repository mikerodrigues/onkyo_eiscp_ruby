onkyo_eiscp_ruby
================

A Ruby implementation of eISCP for controlling Onkyo receivers.

**This code is still under heavy development and using it might make you sick.**
  * Create ISCP messages and eISCP packets
	require 'eiscp'
	iscp_message = ISCPMessage.new("PWR", "01")
eiscp_packet = EISCPPacket.new(iscp_message.message)
  * Send/Recieve UDP eISCP messages
  * Open a TCP socket to send commands and receive solicited and non-solicited status updates.
  * Mock reciever (currently only responds to discovery)

**Inspired by https://github.com/miracle2k/onkyo-eiscp
