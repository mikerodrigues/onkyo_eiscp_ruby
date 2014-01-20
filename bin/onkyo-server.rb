#!/usr/bin/env ruby

require 'eiscp/mock_receiver'

puts "Starting server on 60128..."

EISCP::MockReceiver.new
