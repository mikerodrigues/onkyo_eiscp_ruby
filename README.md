onkyo_eiscp_ruby
================
[![Gem Version](https://badge.fury.io/rb/onkyo_eiscp_ruby.png)](http://badge.fury.io/rb/onkyo_eiscp_ruby)
[![GitHub version](https://badge.fury.io/gh/mikerodrigues%2Fonkyo_eiscp_ruby.png)](http://badge.fury.io/gh/mikerodrigues%2Fonkyo_eiscp_ruby)

*A Ruby implementation of eISCP for controlling Onkyo receivers.*

**I'm still sort of updating this code. Please feel free to reach out if there's something you need that it doesn't do, I may be willing to help.**

**The python version linked below sees much more activity.**

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

* Reasonable variants for human-readable commands (ex. `main-volume` or`volume
` as opposed to `master-volume`)

* Model compatability checking

* Logging

* Exhaustive testing and documentation

Using the Library
-----------------
* require the library

		require 'eiscp'

* You might want to `include EISCP` if you know you won't pollute your namespace
  with Constants under `EISCP` (`Dictionary`, `Message`, `Parser`, `Receiver`,
  `VERSION`)

* You can do most everything through the `Receiver` and `Message` objects. If you
  want to accept user input you will probably want to use the Parser module. Be
  sure to check out the RDocs or dig through the source code. I try to keep it
  well commented/documented, and there's more functionality to the library than
  is shown here:

* The `Message` object is pretty self explanatory. `Message.new` is mostly used
  internally, but you're better off using `Parser.parse` to create them. You
  probably will want to interact with `Message` objects to get information:

```ruby		
		msg = EISCP::Message.new(command: 'PWR', value: '01')
		msg.zone                => 'main'
		msg.command             => "PWR"
		msg.value               => "01"
		msg.command_name        => "system-power"
		msg.command_description => "System Power Command"
		msg.value_name          => "on"
		msg.value_description   => "sets System On"
```

* Discover local receivers (returns an `Array` of `Receiver` objects)

```ruby		
		EISCP::Receiver.discover
```

* Create `Receiver` object from first discovered Receiver on the LAN

```ruby		
		receiver = EISCP::Receiver.new
```

* Or create one manually by IP address or hostname

```ruby		
		receiver = EISCP::Receiver.new('10.0.0.132')
```

* When you create a `Receiver` object with a callback block it will
  connect and call your block on each message received.:

```ruby
		receiver = EISCP::Receiver.new do |msg|
		  puts msg.command
		  puts msg.value
		end
```

* Receivers created without a block will not connect automatically. You can use
  the `connect` method to create a socket and connect to the receiver.

```ruby
		receiver.connect
```

* You can also set or change the callback block later. This will kill the 
  existing callback thread, recreate the socket if necessary and start
  a new callback thread using the provided block:

```ruby		
		receiver.connect do |msg|
		  puts "Received: #{msg.command_name}:#{msg.value_name}"
		end
```

* You can also disconnect, which will close the socket and kill the connection
  thread:

```ruby
		receiver.disconnect
```

* Get information about the Receiver:
	
```ruby		
		receiver.model => "TX-NR609"
		receiver.host  => "10.0.0.111"
		receiver.port  => 60128
		receiver.mac_address => "001122334455"
		receiver.area => "DX"
```

* Receivers now have a `@state` hash that contains a mapping of commands and
  values received. You can use this see the Receiver's last known state without
  querying. Use the `#update_state` method to run every 'QSTN' command in the
  Dictionary and update the state hash, but do note that it will take a few
  seconds to finish:

```ruby
		receiver.update_state
		receiver.state["MVL"] => "22"
		receiver.human_readable_state["master-volume"] => 34
```
		

* You can use `CommandMethods` to easily send a message and return the reply as
  a Message object. Once `Receiver#connect`is called, a method is defined for each command listed in the
  `Dictionary` using the `@command_name` attribute which is 'human readable'.
  You can check the included yaml file or look at the output of 
  `EISCP::Dictionary.commands`. Here a few examples:
		
```ruby		
		# Turn on receiver
		receiver.system_power "on"

		# Query current input source
		receiver.input_selector "query"
		
		# Turn the master volume up one level
		receiver.master_volume "level-up"

		# Set the master volume to 45
		receiver.master_volume "45"
```

* Parse ISCP and human readable strings:

```ruby     		
		# Parse various ISCP strings 
		iscp_message = EISCP::Parser.parse "PWR01"
		iscp_message = EISCP::Parser.parse "PWR 01"
		iscp_message = EISCP::Parser.parse "!1PWR01"
		iscp_message = EISCP::Parser.parse "!1PWR 01"

		# Parse human readable,
		EISCP::Parser.parse("main-volume 34")
```

* `Parser.parse` is also used internally by `Receiver` to parse raw eISCP socket
  data.


Using the Binaries
------------------

* Discover local receivers

	`$ onkyo.rb -d`
		
* Send a human-readable command

	`$ onkyo.rb system-power on  # uses Parser.parse`

* Or send a raw command

	`$ onkyo.rb PWRQSTN   # Also tries to use Parser.parse`

* Monitor the first discovered receiver to see status updates

	`$ onkyo.rb -m`

* Start the mock server (only responds to 'ECNQSTN')

	`$ onkyo-server.rb`

* Turn off the first receiver discovered:

	`$ onkyo.rb system-power off`

* List all known commands and values:

	`$ onkyo.rb -L`

* List all known commands known to work with discovered models:

	`$ onkyo.rb -l`

Contributing
------------

* Open an issue describing bug or feature
* Fork repo
* Create a branch
* Send pull request
