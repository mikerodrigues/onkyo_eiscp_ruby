# frozen_string_literal: true

# Library for controlling Onkyo receivers over TCP/IP.
#
module EISCP
  VERSION = '2.1.7'
end

require_relative './eiscp/receiver'
require_relative './eiscp/message'
require_relative './eiscp/dictionary'
require_relative './eiscp/parser'
