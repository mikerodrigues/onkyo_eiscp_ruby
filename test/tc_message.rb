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

  def test_parse_discovery_iscp_message
    assert_equal(EISCP::Message.parse('!xECNQSTN').to_iscp, '!xECNQSTN')
  end

  def test_parse_iscp_messages
    assert_equal(EISCP::Message.parse('PWR 01').to_iscp, '!1PWR01')
    assert_equal(EISCP::Message.parse('PWR01').to_iscp, '!1PWR01')
    assert_equal(EISCP::Message.parse('!1PWR01').to_iscp, '!1PWR01')
    assert_equal(EISCP::Message.parse('!1PWR 01').to_iscp, '!1PWR01')
  end

  def test_return_nil_for_invalid_message
    assert_equal(EISCP::Message.parse('!FAK 01'), nil)
  end

  def test_create_discovery_packet_string
    assert_equal(DISCOVERY_PACKET.to_eiscp, DISCOVERY_STRING)
  end

  def test_parse_discovery_packet_string
    assert_equal(EISCP::Message.parse(DISCOVERY_STRING).to_eiscp, DISCOVERY_PACKET.to_eiscp)
  end

  def test_parse_human_readable
    assert_equal(EISCP::Message.parse('system-power on'), EISCP::Message.new(command: 'PWR', value: '01'))
    assert_equal(EISCP::Message.parse('main system-power on'), EISCP::Message.new(command: 'PWR', value: '01'))
  end

  def test_return_nil_for_fake_human_readable
    assert_equal(EISCP::Message.parse('fake-command value'), nil)
  end

  def test_validate_valid_message_with_variable
    # Commands that return something unexpected like an artist name
  end
end
