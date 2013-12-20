require_relative "../lib/eiscp/eiscp_packet.rb"
require "test/unit"

class TestEISCPPacket < Test::Unit::TestCase

  def test_create_discovery_packet_string
    assert_equal(EISCPPacket.new("!xECNQSTN").packet_string, "ISCP\x00\x00\x00\x10\x00\x00\x00\t\x01\x00\x00\x00!xECNQSTN")
  end

  def test_parse_discovery_packet_string
    assert_equal(EISCPPacket.parse(EISCPPacket.new("!xECNQSTN").packet_string), ["ISCP", 16, 9, "\x01", "", "!xECNQSTN"])
  end

end
