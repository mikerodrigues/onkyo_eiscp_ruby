onkyo_eiscp_ruby
================

A Ruby implementation of eISCP for controlling Onkyo receivers.

**This code is still under heavy development and using it might make you sick.**
* Create ISCP messages and eISCP packets
* Automatically discover receiver's in the broadcast domain
* Send/Recieve eISCP messages
* Open a TCP socket to send commands and receive solicited and non-solicited status updates.
* Mock reciever (currently only responds to discovery)

**Inspired by https://github.com/miracle2k/onkyo-eiscp

**Protocol information from http://michael.elsdoerfer.name/onkyo/ISCP-V1.21_2011.xls

Usage
________________

	# require the library

	require 'eiscp'
	
	# Discover local receivers
	EISCP::Receiver.discover
	
	
	# Open a TCP connection to monitor solicited updates
	receiver = Receiver.new('10.0.0.1')
	receiver.connect

	# You can also pass a block and operate on received packet strings:
	receiver.connect do |data|
	  puts EISCP::Receiver.parse(data).iscp_message
	end

	# Turn on the receiver
	message = EISCP::Message.parse("PWR", "01")
	message.send(message.to_eiscp)

	# New 'parse' method makes creating EISCP objects more flexible
	# This parses messages from command line or raw eiscp data from the socket
	
	# Various command line styles:
        iscp_message = EISCP::Message.parse "PWR01"
	iscp_message = EISCP::Message.parse "PWR 01"
	iscp_message = EISCP::Message.parse "!1PWR01"
	iscp_message = EISCP::Message.parse "!1PWR 01"

	# Parsing raw socket data
	iscp_message_from_raw_eiscp = EISCP::Message.parse iscp_message.to_eiscp

