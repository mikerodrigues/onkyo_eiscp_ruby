require_relative "../lib/eiscp/eiscp_packet.rb"
require "test/unit"

class TestEISCPPacket < Test::Unit::TestCase

  DISCOVERY_STRING = "ISCP\x00\x00\x00\x10\x00\x00\x00\n\x01\x00\x00\x00!xECNQSTN\r"
  DISCOVERY_PACKET = EISCPPacket.new('ECN', 'QSTN', 'x', '!')

  def test_create_discovery_packet_string
    assert_equal(DISCOVERY_PACKET.to_s, DISCOVERY_STRING)
  end

  def test_parse_discovery_packet_string
    assert_equal(EISCPPacket.parse(DISCOVERY_STRING).to_s, DISCOVERY_PACKET.to_s)
  end

end
