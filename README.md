onkyo_eiscp_ruby
================
[![Gem Version](https://badge.fury.io/rb/onkyo_eiscp_ruby.png)](http://badge.fury.io/rb/onkyo_eiscp_ruby)
[![GitHub version](https://badge.fury.io/gh/mikerodrigues%2Fonkyo_eiscp_ruby.png)](http://badge.fury.io/gh/mikerodrigues%2Fonkyo_eiscp_ruby)

A Ruby implementation of eISCP for controlling Onkyo receivers.

**This code is still under heavy development and using it might make you sick.**


Automatically discover receivers in the broadcast domain

Send/Receive eISCP messages to control receivers

Open a TCP socket to receive solicited and non-solicited status updates.

Mock reciever (currently only responds to discovery)

**Inspired by https://github.com/miracle2k/onkyo-eiscp

**Protocol information from http://michael.elsdoerfer.name/onkyo/ISCP-V1.21_2011.xls



Using the Library
-----------------
* require the library

		require 'eiscp'

* Discover local receivers

		EISCP::Receiver.discover

* Create Receiver object from first discovered

		Receiver.new

* Open a TCP connection to monitor solicited updates

		receiver = Receiver.new('10.0.0.1')
		receiver.connect

* You can also pass a block and operate on received packet strings:

		receiver.connect do |data|
		  puts EISCP::Receiver.parse(data).iscp_message
		end

* Turn on the receiver

		message = EISCP::Message.parse("PWR", "01")
		message.send(message.to_eiscp)

* New 'parse' method makes creating EISCP objects more flexible.
This parses messages from command line or raw eiscp data from the socket
        
		iscp_message = EISCP::Message.parse "PWR01"
		iscp_message = EISCP::Message.parse "PWR 01"
		iscp_message = EISCP::Message.parse "!1PWR01"
		iscp_message = EISCP::Message.parse "!1PWR 01"

* Parsing raw socket data

		iscp_message_from_raw_eiscp = EISCP::Message.parse iscp_message.to_eiscp

Using the Binaries
------------------

* Discover local receivers

		$ onkyo.rb -d
		
* Send a raw command
 		
		$ onkyo.rb PWR01 # or any string accepted by EISCP::Message.parse

* Connect to the first discovered receiver to see status updates

		$ onkyo.rb -c

* Start the mock server (only responds to 'ECNQSTN')

		$ onkyo-server.rb
