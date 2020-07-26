#!/usr/bin/env ruby
# frozen_string_literal: true

require 'eiscp/mock_receiver'

puts 'Starting server on 60128...'

EISCP::MockReceiver.new
