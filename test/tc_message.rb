require_relative "../lib/eiscp/message"
require "minitest/autorun"

class TestMessage <  MiniTest::Test

  
  DISCOVERY_PACKET = EISCP::Message.new('ECN', 'QSTN', "\r\n", 'x', '!')
  DISCOVERY_STRING = DISCOVERY_PACKET.to_eiscp


  def test_create_discovery_iscp_message
    assert_equal(EISCP::Message.new('ECN', 'QSTN', "\r\n",  'x', '!').to_iscp, '!xECNQSTN')
  end

  def test_parse_discovery_iscp_message
    assert_equal(EISCP::Message.parse('!xECNQSTN').to_iscp, '!xECNQSTN')
  end

  def test_create_discovery_packet_string
    assert_equal(DISCOVERY_PACKET.to_eiscp, DISCOVERY_STRING)
  end

  def test_parse_discovery_packet_string
    assert_equal(EISCP::Message.parse(DISCOVERY_STRING).to_eiscp, DISCOVERY_PACKET.to_eiscp)
  end

  def test_validate
    assert_equal(DISCOVERY_PACKET.valid?, true)
    assert_equal(EISCP::Message.new('BAD', 'MSG'), false)
  end

end
