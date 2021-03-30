# frozen_string_literal: true

require_relative '../lib/eiscp/parser'
require_relative '../lib/eiscp/message'
require 'minitest/autorun'

class TestParser < MiniTest::Test
  DISCOVERY_PACKET = EISCP::Message.new(command: 'ECN', value: 'QSTN', terminator: "\r\n", unit_type: 'x', start: '!')
  DISCOVERY_STRING = DISCOVERY_PACKET.to_eiscp

  def test_parse_discovery_iscp_message
    assert_equal(EISCP::Parser.parse('!xECNQSTN').to_iscp, '!xECNQSTN')
  end

  def test_parse_iscp_messages
    assert_equal(EISCP::Parser.parse('PWR 01').to_iscp, '!1PWR01')
    assert_equal(EISCP::Parser.parse('PWR01').to_iscp, '!1PWR01')
    assert_equal(EISCP::Parser.parse('!1PWR01').to_iscp, '!1PWR01')
    assert_equal(EISCP::Parser.parse('!1PWR 01').to_iscp, '!1PWR01')
  end

  def test_parse_discovery_packet_string
    assert_equal(EISCP::Parser.parse(DISCOVERY_STRING).to_eiscp, DISCOVERY_PACKET.to_eiscp)
  end

  def test_parse_human_readable
    assert_equal(EISCP::Parser.parse('system-power on'), EISCP::Message.new(command: 'PWR', value: '01'))
    assert_equal(EISCP::Parser.parse('main system-power on'), EISCP::Message.new(command: 'PWR', value: '01'))
  end

  def test_return_nil_for_fake_human_readable
    assert_nil(EISCP::Parser.parse('fake-command value'))
  end
end
