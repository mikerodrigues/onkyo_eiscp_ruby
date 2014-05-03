onkyo_eiscp_ruby
================
[![Gem Version](https://badge.fury.io/rb/onkyo_eiscp_ruby.png)](http://badge.fury.io/rb/onkyo_eiscp_ruby)
[![GitHub version](https://badge.fury.io/gh/mikerodrigues%2Fonkyo_eiscp_ruby.png)](http://badge.fury.io/gh/mikerodrigues%2Fonkyo_eiscp_ruby)

A Ruby implementation of eISCP for controlling Onkyo receivers.

**This code is still under heavy development and using it might make you sick.**


Automatically discover receivers in the broadcast domain

Send commands to receivers and parse returned messages

Open a TCP socket to receive solicited and non-solicited status updates.

Mock reciever (currently only responds to discovery)

Human-readable commands

**Inspired by https://github.com/miracle2k/onkyo-eiscp

**Protocol information from http://michael.elsdoerfer.name/onkyo/ISCP-V1.21_2011.xls

What's missing?
---------------
* Command validation

* Parsing of all human readable commands (run the tests to see some commands that aren't parsable in human readable form yet.

* Reasonable variants for human-readable commands (ex. "main-volume" or "volume"
  as opposed to "master-volume".

* Model compatability checking

* Logging

* Exhaustive testing and documentation




Using the Library
-----------------
* require the library

		require 'eiscp'

* Discover local receivers

		EISCP::Receiver.discover

* Create Receiver object from first discovered

		receiver = EISCP::Receiver.new

* Or create one manually by IP address or hostname

		receiver = EISCP::Receiver.new('10.0.0.132')

* Open a TCP connection to monitor solicited updates

		receiver.connect

* You can also pass a block and operate on received packet strings:

		receiver.connect do |data|
		  puts EISCP::Command.parse(data).iscp_message
		end

* Turn on the receiver

		message = EISCP::Message.parse("PWR", "01")
		message.send(message.to_eiscp)

* Parse incoming messages and the following formats:
        
		iscp_message = EISCP::Message.parse "PWR01"
		iscp_message = EISCP::Message.parse "PWR 01"
		iscp_message = EISCP::Message.parse "!1PWR01"
		iscp_message = EISCP::Message.parse "!1PWR 01"

* Parsing raw socket data

		iscp_message = EISCP::Message.parse iscp_message.to_eiscp

* Human-readable commands

		EISCP::Command.parse("main-volume 34")

* Human-readable methods and parameters ( you can use "_" in place of "-" in
  methods or parameters

		receiver.master_volume("level-up")



Using the Binaries
------------------

* Discover local receivers

		$ onkyo.rb -d
		
* Send a raw command
 		
		$ onkyo.rb PWR01 # or any string accepted by EISCP::Command.parse

* Connect to the first discovered receiver to see status updates

		$ onkyo.rb -c

* Start the mock server (only responds to 'ECNQSTN')

		$ onkyo-server.rb

* Turn off the first receiver discovered:

		$ onkyo.rb system-power off


Contributing
------------

* Open an issue describing bug or feature
* Fork repo
* Create a branch
* Send pull request
