require_relative "../lib/eiscp/iscp_message.rb"
require "test/unit"

class TestISCPMessage <  Test::Unit::TestCase

  DISCOVERY_STRING = "ISCP\x00\x00\x00\x10\x00\x00\x00\n\x01\x00\x00\x00!xECNQSTN"
  DISCOVERY_PACKET = EISCPPacket.new('ECN', 'QSTN', 'x', '!')



  def test_create_discovery_iscp_message
    assert_equal(ISCPMessage.new("ECN", "QSTN", "x", "!").to_iscp, "!xECNQSTN")
  end

  def test_parse_discovery_iscp_message
    assert_equal(ISCPMessage.parse("!xECNQSTN").to_iscp, "!xECNQSTN")
  end

  def test_create_discovery_packet_string
    assert_equal(DISCOVERY_PACKET.to_eiscp, DISCOVERY_STRING)
  end

  def test_parse_discovery_packet_string
    assert_equal(ISCPMessage.parse(DISCOVERY_STRING).to_eiscp, DISCOVERY_PACKET.to_eiscp)
  end

end
