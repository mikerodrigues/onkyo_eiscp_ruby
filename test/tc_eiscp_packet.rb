require_relative "../lib/eiscp/eiscp_packet.rb"
require "test/unit"

class TestEISCPPacket < Test::Unit::TestCase

  DISCOVERY_STRING = "ISCP\x00\x00\x00\x10\x00\x00\x00\t\x01\x00\x00\x00!xECNQSTN"
  DISCOVERY_PACKET = EISCPPacket.new('!xECNQSTN')

  def test_create_discovery_packet_string
    assert_equal(DISCOVERY_PACKET.packet_string, DISCOVERY_STRING)
  end

  def test_parse_discovery_packet_string
    assert_equal(EISCPPacket.parse(DISCOVERY_STRING), DISCOVERY_PACKET)
  end

end
