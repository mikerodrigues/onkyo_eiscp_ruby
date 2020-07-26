# frozen_string_literal: true

require_relative '../lib/eiscp/message'
require 'minitest/autorun'

class TestMessage <  MiniTest::Test
  DISCOVERY_PACKET = EISCP::Message.new(command: 'ECN', value: 'QSTN', terminator: "\r\n", unit_type: 'x', start: '!')
  DISCOVERY_STRING = DISCOVERY_PACKET.to_eiscp

  def test_create_discovery_iscp_message
    assert_equal(EISCP::Message.new(command: 'ECN', value: 'QSTN', terminator: "\r\n", unit_type: 'x', start: '!').to_iscp, '!xECNQSTN')
  end

  def test_create_messages
    assert_equal(EISCP::Message.new(command: 'PWR', value: '01').to_iscp, '!1PWR01')
    assert_equal(EISCP::Message.new(command: 'MVL', value: 'QSTN').to_iscp, '!1MVLQSTN')
  end

  def test_create_discovery_packet_string
    assert_equal(DISCOVERY_PACKET.to_eiscp, DISCOVERY_STRING)
  end

  def test_validate_valid_message_with_variable
    # Commands that return something unexpected like an artist name
  end
end
